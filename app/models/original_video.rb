class OriginalVideo < Video
  before_validation(:on => :create) {:set_status_and_format}

  validates_presence_of :video_file_name
  validates_presence_of :lesson, :status
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true
  has_attached_file :video,
                    :storage        => :s3,
                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                    :s3_permissions => 'private',
                    :path           => "#{(ENV['s3_dir'] and Rails.env.development?) ? ENV['s3_dir'] : APP_CONFIG[CONFIG_S3_DIRECTORY]}/:attachment/:id/:basename.:extension",
                    :bucket         => APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET]
  #:url => "/assets/videos/:id/:basename.:extension",
  #:path => ":rails_root/public/assets/videos/:id/:basename.:extension"

  validates_attachment_presence :video
  validates_attachment_size :video, :less_than => APP_CONFIG[CONFIG_MAX_VIDEO_SIZE].megabytes
  validates_attachment_content_type :video, :content_type => ['application/x-avi',
                                                              'video/x-msvideo',
                                                              'video/avi',
                                                              'video/quicktime',
                                                              'video/3gpp',
                                                              'video/x-ms-wmv',
                                                              'video/mp4',
                                                              'video/x-m4v',
                                                              'video/mpeg',
                                                              'video/x-flv',
                                                              'application/x-flash-video',
                                                              'application/x-itunes-itlp']
  # 'application/x-swf',
  # 'application/x-shockwave-flash'

  def set_url
    # The environment.yml files aren't set for task_scheduler, so manually calculate the video path here'
    video_path = "#{self.s3_root_dir}/videos/#{self.id}/#{self.video_file_name}"
    self.update_attributes!(:s3_key  => video_path,
                            :s3_path => "s3://#{APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET]}/#{video_path}",
                            :url     => "http://#{APP_CONFIG[CONFIG_CDN_OUTPUT_SERVER]}/#{video_path}")
  end

  # Call out to flixcloud to trigger a conversion process
  def create_processed_video(clazz)
    set_url
    processed_video = clazz.find(:first, :conditions => {:lesson_id => self.lesson})
    unless processed_video
      processed_video = clazz.create!(:lesson_id            => self.lesson.id,
                                      :video_file_name      => self.video_file_name,
                                      :s3_key               => self.s3_key,
                                      :processed_video_cost => 0,
                                      :input_video_cost     => 0,
                                      :converted_from_video => self,
                                      :s3_root_dir          => self.s3_root_dir)
    end
    begin
      grant_s3_permissions_to_flix
    rescue Exception => e
      # rethrow the exception so we see the error in the periodic jobs log
      processed_video.change_status(VIDEO_STATUS_FAILED, e.message)
      raise e
    end
    processed_video
  end


  # Call out to flixcloud to trigger a conversion process
  def process_video(full_processed_video, preview_video, notify_path)
    full_processed_video.update_processed_video_attributes
    preview_video.update_processed_video_attributes

    Zencoder.api_key = FLIX_API_KEY

    notifications    = ['admin@firehoze.com']
    notifications << notify_path if Rails.env.production?
    notification_str = notifications.collect { |x| "\"#{x}\"" }.join(', ')
    params           =
        <<-eos
{
  "input": "   #{s3_path}   ",
  "outputs": [
    {
      "label": "FullProcessedVideo",
      "video_codec": "vp6",
      "speed": 2,
      "url": "#{full_processed_video.output_ftp_path}",
      "width": "960",
      "height": "720",
      "upscale": "true",
      "aspect_mode": "preserve",
      "quality": 4,
      "watermark": {
        "url": "#{WATERMARK_URL}",
        "x": "-2%",
        "y": "-2%"
      },
      "thumbnails": {
        "times": [10, 25],
        "size": "#{PLAYER_WIDTH}x#{PLAYER_HEIGHT}",
        "base_url": "#{full_processed_video.thumbnail_s3_path}",
        "prefix": "thumb"
      },
      "notifications": [
        #{notification_str}
      ]
    },
    {
      "label": "PreviewProcessedVideo",
      "video_codec": "vp6",
      "speed": 2,
      "url": "#{preview_video.output_ftp_path}",
      "width": "960",
      "height": "720",
      "upscale": "true",
      "aspect_mode": "preserve",
      "quality": 4,
      "clip_length": "00:00:30",
      "watermark": {
        "url": "#{WATERMARK_URL}",
        "x": "-2",
        "y": "-2"
      },
      "thumbnails": {
        "times": [10, 25],
        "size": "#{PLAYER_WIDTH}x#{PLAYER_HEIGHT}",
        "base_url": "#{preview_video.thumbnail_s3_path}",
        "prefix": "thumb"
      },
      "notifications": [
        #{notification_str}
      ]
    }
  ]
}
    eos
#        "#{notify_path}",
    puts params
    response = Zencoder::Job.create(params)

    if response.success?
      puts "submitted successfully"
      full_processed_video.change_status(VIDEO_STATUS_CONVERTING, " (##{response.body['id']})")
      full_processed_video.update_attributes!(:flixcloud_job_id      => response.body['id'],
                                              :conversion_started_at => Time.now)
      preview_video.change_status(VIDEO_STATUS_CONVERTING, " (##{response.body['id']})")
      preview_video.update_attributes!(:flixcloud_job_id      => response.body['id'],
                                       :conversion_started_at => Time.now)
      RunOncePeriodicJob.create!(:name        => 'DetectZombieVideoProcess',
                                 :job         => "ProcessedVideo.detect_zombie_video(#{full_processed_video.id}, #{response.body['id']})",
                                 :next_run_at => (APP_CONFIG[CONFIG_ZOMBIE_VIDEO_PROCESS_MINUTES].to_i.minutes.from_now))
    else
      msg = "conversion failed with response code #{response.code} #{response.body}"
      full_processed_video.change_status(VIDEO_STATUS_FAILED, msg)
      preview_video.change_status(VIDEO_STATUS_FAILED, msg)
      raise msg
    end
  end

  # First call out to Amazon S3 to grant permissions to flixcloud to view the raw video,
  # then trigger a video conversion at flixcloud itself
  def self.convert_video video_id, notify_url
    video = OriginalVideo.find(video_id)

    video.process_video(video.create_processed_video(FullProcessedVideo), video.create_processed_video(PreviewProcessedVideo), notify_url)

  rescue Exception => e
    Lesson.transaction do
      video.lesson.update_attribute(:status, VIDEO_STATUS_FAILED)
    end
    # rethrow the exception so we see the error in the periodic jobs log
    raise e
  end

  private

  def set_status_and_format
    self.status      = VIDEO_STATUS_READY
    self.s3_root_dir = APP_CONFIG[CONFIG_S3_DIRECTORY]
  end
end