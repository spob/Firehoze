class OriginalVideo < Video
  before_validation_on_create :set_status_and_format

  validates_presence_of :video_file_name
  validates_presence_of :lesson, :format, :status
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true
  has_attached_file :video,
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :s3_permissions => 'private',
                    :path => "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/:attachment/:id/:basename.:extension",
                    :bucket => APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET]
  #:url => "/assets/videos/:id/:basename.:extension",
  #:path => ":rails_root/public/assets/videos/:id/:basename.:extension"

  validates_attachment_presence :video
  validates_attachment_size :video, :less_than => APP_CONFIG[CONFIG_MAX_VIDEO_SIZE].megabytes
  validates_attachment_content_type :video, :content_type => [ 'application/x-avi',
                                                               'video/x-msvideo',
                                                               'video/avi',
                                                               'video/quicktime',
                                                               'video/3gpp',
                                                               'video/x-ms-wmv',
                                                               'video/mp4',
                                                               'video/mpeg',
                                                               'video/x-flv',
                                                               'application/x-flash-video']
  # 'application/x-swf',
  # 'application/x-shockwave-flash'

  def set_url
    # The environment.yml files aren't set for task_scheduler, so manually calculate the video path here'
    video_path = "#{self.s3_root_dir}/videos/#{self.id}/#{self.video_file_name}"
    self.update_attributes!(:s3_key => video_path,
                            :s3_path => "s3://#{APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET]}/#{video_path}",
                            :url => "#{APP_CONFIG[CONFIG_CDN_URL]}/#{video_path}")
  end

  # Call out to flixcloud to trigger a conversion process
  def trigger_convert
    processed_video = ProcessedVideo.find(:first, :conditions => { :lesson_id => self.lesson})
    unless processed_video
      processed_video = ProcessedVideo.create!(:lesson_id => self.lesson.id,
                                               :video_file_name => self.video_file_name,
                                               :s3_key => self.s3_key,
                                               :converted_from_video => self,
                                               :s3_root_dir => self.s3_root_dir)
    end
    begin
      set_url
      grant_s3_permissions_to_flix
    rescue Exception => e
      # rethrow the exception so we see the error in the periodic jobs log
      processed_video.change_status(VIDEO_STATUS_FAILED, e.message)
      raise e
    end
    processed_video.convert
  end

  # First call out to Amazon S3 to grant permissions to flixcloud to view the raw video,
  # then trigger a video conversion at flixcloud itself
  def self.convert_video video_id
    video = OriginalVideo.find(video_id)

    unless video.trigger_convert
      raise "Starting conversion failed"
    end

  rescue Exception => e
    Lesson.transaction do
      video.lesson.update_attribute(:status, VIDEO_STATUS_FAILED)
    end
    # rethrow the exception so we see the error in the periodic jobs log
    raise e
  end

  private

  def set_status_and_format
    self.status = VIDEO_STATUS_READY
    self.format = VIDEO_FORMAT_ORIGINAL
    self.s3_root_dir = APP_CONFIG[CONFIG_S3_DIRECTORY]
  end
end