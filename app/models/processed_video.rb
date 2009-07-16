class ProcessedVideo < Video
  before_validation_on_create :set_status_and_format

  belongs_to :converted_from_video, :class_name => 'OriginalVideo'
  validates_presence_of :video_file_name
  validates_presence_of :lesson, :format, :status
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true


  named_scope :by_format,
              lambda{ |format| {:conditions => { :format => format}}
              }

  # Call out to flixcloud to trigger a conversion process
  def convert
    lesson.change_state(LESSON_STATE_START_CONVERSION)
    job = FlixCloud::Job.new(:api_key => FLIX_API_KEY,
                             :recipe_id => FLIX_RECIPE_ID,
                             :input_url => self.converted_from_video.s3_path,
                             :output_url => output_path,
                             :watermark_url => WATERMARK_URL,
                             :thumbnails_url => thumbnail_path)
    if job.save
      lesson.change_state(LESSON_STATE_START_CONVERSION_SUCCESS, " (##{job.id})")
      self.update_attributes!(:flixcloud_job_id => job.id,
                              :conversion_started_at => job.initialized_at,
                              :status => 'Converting')
      RunOncePeriodicJob.create!(:name => 'DetectZombieVideoProcess',
                                 :job => "Lesson.detect_zombie_video #{self.id}, #{job.id}",
                                 :next_run_at => (APP_CONFIG[CONFIG_ZOMBIE_VIDEO_PROCESS_MINUTES].to_i.minutes.from_now))
    else
      msg = ""
      job.errors.each { |x| msg = (msg == "" ?  "" : ", ") + msg + x}
      self.update_attributes!(:video_transcoding_error => msg, :status => "Failed")
      raise msg
    end
  end

  # This method takes a job record populated from the flixcloud gem, and will update the various attributes
  # on the job accordingly.
  def finish_conversion job
    Video.transaction do
      if job.successful?
        self.update_attributes(
                :conversion_ended_at => job.finished_job_at,
                :video_width => job.output_media_file.width,
                :video_height => job.output_media_file.height,
                :video_file_size => job.output_media_file.size,
                :video_duration => job.output_media_file.duration,
                :processed_video_cost => job.output_media_file.cost,
                :input_video_cost => job.input_media_file.cost,
                :thumbnail_url => "http://" + APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET] +
                        ".s3.amazonaws.com/" + id.to_s + "/thumb_0000.png",
                :s3_path => job.output_media_file.url,
                :url => "http://#{APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET]}.s3.amazonaws.com/#{self.s3_key}.flv")
        self.lesson.update_attribute(:video_duration, job.output_media_file.duration)
        self.lesson.change_state(LESSON_STATE_READY)
        Notifier.deliver_lesson_ready self.lesson
      else
        self.lesson.change_state(LESSON_STATE_FAILED, job.error_message)
        Notifier.deliver_lesson_processing_failed self.lesson
      end
    end
    job.successful?
  rescue Exception => e
    self.lesson.change_state(LESSON_STATE_FAILED, 'failed: ' + e.message)
    raise e
  end

  #def set_thumbnail_url
  #  self.lesson.change_state(LESSON_STATE_GET_THUMBNAIL_URL)
  #s3_connection = s3_connect
  #bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET])
  #file = bucket.key(thumbnail_path + "/thumb_0000.png", true)
  #url =
  #self.self.update_attribute(:thumbnail_url, url)
  #grantee = RightAws::S3::Grantee.new(bucket, FLIX_CLOUD_AWS_ID, 'READ', :apply)
  #grantee = RightAws::S3::Grantee.new(file, FLIX_CLOUD_AWS_ID, 'READ', :apply)
  #end

  private

  def output_path
    's3://' + APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET] + '/' + self.s3_key + ".flv"
  end

  def thumbnail_path
    's3://' + APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET] + "/" + self.id.to_s
  end

  def set_status_and_format
    self.status = 'pending'
    self.format = 'Flash'
  end
end