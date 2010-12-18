class ProcessedVideo < Video
  belongs_to :lesson, :counter_cache => true
  before_validation_on_create :set_video_status

  belongs_to :converted_from_video, :class_name => 'OriginalVideo'
  validates_presence_of :video_file_name
  validates_presence_of :lesson, :status
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true

  def update_processed_video_attributes
    self.update_attributes!(:s3_key            => "#{self.s3_root_dir}/videos/#{self.id}/#{self.video_file_name}.flv",
                            :thumbnail_s3_path => thumbnail_s3_path)
  end

  # This method takes a job record populated from the flixcloud gem, and will update the various attributes
  # on the job accordingly.
  def finish_conversion job
    Video.transaction do
      output_media_file = nil
      job['output_media_files'].each do |output|
        output_media_file = output if output['label'] == self.class.name
      end

      if output_media_file && output_media_file['state'] == 'finished'
        self.update_attributes(
            :conversion_ended_at     => output_media_file['finished_at'],
            :video_width             => output_media_file['width'],
            :video_height            => output_media_file['height'],
            :video_file_size         => output_media_file['file_size_bytes'],
            :video_duration          => output_media_file['duration_in_ms'],
            :video_file_name         => output_media_file['url'][/[^\/]*\z/],
            :video_content_type      => 'application/x-flv',
            :processed_video_cost    => 0, #zero_nvl(self.processed_video_cost) + job.output_media_file.cost.to_f,
            :input_video_cost        => 0,
            :video_transcoding_error => nil,
            :thumbnail_url           => (thumbnail_path),
            :s3_path                 => output_media_file['url'],
            :s3_key                  => self.calc_s3_key,
            :url                     => "http://#{APP_CONFIG[CONFIG_CDN_OUTPUT_SERVER]}/#{self.s3_key}")

        update_lesson_attributes(output_media_file['duration_in_ms'])
        make_thumbnail_public
        make_video_public

        self.change_status(VIDEO_STATUS_READY)
      else
        if output_media_file
          self.change_status(VIDEO_STATUS_FAILED, output_media_file['error_message'])
        else
          self.change_status(VIDEO_STATUS_FAILED, "Unable to find output_media_file for #{job['id']} #{self.class.name}")
        end
        Notifier.deliver_lesson_processing_failed self
      end
      output_media_file && output_media_file['state'] == 'finished'
    end

  rescue Exception => e
    self.change_status(VIDEO_STATUS_FAILED, ': ' + e.message)
    raise e
  end

  def make_thumbnail_public
    s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                                     APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
    bucket        = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET])
    file          = bucket.key("#{thumbnail_directory}/thumb_0001.png", true)
    RightAws::S3::Grantee.new(file, ALL_USERS_AWS_ID, 'READ', :apply)
  end

  # Allow flixcloud to view the raw video
  def make_video_public
    s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                                     APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
    bucket        = s3_connection.bucket("videos.firehoze.com")
    file          = bucket.key(self.s3_key, true)
    grantee       = RightAws::S3::Grantee.new(bucket, ALL_USERS_AWS_ID, 'READ', :apply)
    grantee       = RightAws::S3::Grantee.new(file, ALL_USERS_AWS_ID, 'READ', :apply)
  end

  def change_status(new_status, msg=nil)
    self.video_status_changes.create!(:from_status => self.status,
                                      :to_status   => new_status,
                                      :lesson      => self.lesson,
                                      :message     => msg)
    self.reload
    self.update_attributes!(:status                  => new_status,
                            :video_transcoding_error => (status == VIDEO_STATUS_FAILED ? msg : nil))
    self.lesson.update_status
  end

# Check if a video was submitted for processing and never returned. If so, send an email alert
  def self.detect_zombie_video(video_id, job_id)
    video = ProcessedVideo.find(video_id)
    if video.flixcloud_job_id == job_id
      # id is the same, so a new job hasn't been submitted
      if video.status == VIDEO_STATUS_CONVERTING
        # still in a processing state
        Notifier.deliver_lesson_processing_hung video.lesson
      end
    end
  end

  def thumbnail_path(size=thumbnail_size)
    thumbnail = "http://#{APP_CONFIG[CONFIG_CDN_THUMBS_SERVER]}/#{self.s3_root_dir}/thumbs/#{lesson.id.to_s}/#{size}/thumb_0001.png"
  end

  def thumbnail_s3_path
    "s3://#{APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET]}/#{thumbnail_directory}"
  end

  def thumbnail_directory
    "#{self.s3_root_dir}/thumbs/#{lesson.id.to_s}/#{thumbnail_size}"
  end

  def calc_s3_key
    "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/videos/#{self.id.to_s}/#{self.class.name == "FullProcessedVideo" ? "full" : "preview"}.flv"
  end

  private

  def zero_nvl(value)
    if value.nil? or value.blank?
      0.0
    else
      value
    end
  end

  def set_video_status
    self.status = VIDEO_STATUS_PENDING
  end
end