class ProcessedVideo < Video
  before_validation_on_create :set_status_and_format

  belongs_to :converted_from_video, :class_name => 'OriginalVideo'
  validates_presence_of :video_file_name
  validates_presence_of :lesson, :format, :status
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true

  before_create :record_status_change_create

  named_scope :by_format,
              lambda{ |format| {:conditions => { :format => format}}
              }

  # Call out to flixcloud to trigger a conversion process
  def convert
    job = FlixCloud::Job.new(:api_key => FLIX_API_KEY,
                             :recipe_id => FLIX_RECIPE_ID,
                             :input_url => self.converted_from_video.s3_path,
                             :output_url => output_path,
                             :watermark_url => WATERMARK_URL,
                             :thumbnails_url => thumbnail_path)
    if job.save
      change_status(VIDEO_STATUS_CONVERTING, " (##{job.id})")
      self.update_attributes!(:flixcloud_job_id => job.id,
                              :conversion_started_at => job.initialized_at,
                              :s3_key => "videos/#{self.id}/#{self.video_file_name}.flv")
      RunOncePeriodicJob.create!(:name => 'DetectZombieVideoProcess',
                                 :job => "ProcessedVideo.detect_zombie_video #{self.id}, #{job.id}",
                                 :next_run_at => (APP_CONFIG[CONFIG_ZOMBIE_VIDEO_PROCESS_MINUTES].to_i.minutes.from_now))
    else
      msg = ""
      job.errors.each { |x| msg = (msg == "" ?  "" : ", ") + msg + x}
      change_status(VIDEO_STATUS_FAILED, msg)
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
                :video_transcoding_error => nil,
                :thumbnail_url => "http://" + APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET] +
                        ".s3.amazonaws.com/" + id.to_s + "/thumb_0000.png",
                :s3_path => job.output_media_file.url,
                :url => "http://#{APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET]}.s3.amazonaws.com/#{self.s3_key}.flv")


        self.lesson.update_attribute(:finished_video_duration, job.output_media_file.duration)
        self.change_status(VIDEO_STATUS_READY)
        Notifier.deliver_lesson_ready self.lesson
      else
        self.change_status(VIDEO_STATUS_FAILED, job.error_message)
        Notifier.deliver_lesson_processing_failed self.lesson
      end
    end
    job.successful?
  rescue Exception => e
    self.change_status(VIDEO_STATUS_FAILED, 'failed: ' + e.message)
    raise e
  end

  def change_status(new_status, msg=nil)
    self.update_attributes(:status => new_status,
                           :video_transcoding_error => (status == VIDEO_STATUS_FAILED ? msg : nil))
    self.lesson.update_attribute(:status, new_status)
    self.video_status_changes.create!(:from_status => self.status_was,
                                       :to_status => self.status,
                                       :lesson => self.lesson,
                                       :message => msg)
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

  # This is a utility method to build a dummy XML response message from flix cloud
  def build_flix_response
    xml = Builder::XmlMarkup.new( :target => out_string = "",
                                  :indent => 2 )

    xml.instruct!(:xml, :encoding => "UTF-8")
    xml.job do
      xml.tag!("finished-job-at", Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"), :type => "datetime")
      xml.tag!("id", self.flixcloud_job_id.to_s, :type => "integer")
      xml.tag!("initialized-job-at", self.conversion_started_at.strftime("%Y-%m-%dT%H:%M:%SZ"), :type => "datetime")
      xml.tag!("recipe-name", "my-recipe")
      xml.tag!("recipe-id", FLIX_RECIPE_ID, :type => "integer")
      xml.tag!('state', 'successful_job')
      xml.tag!('error-message')
      xml.tag!('input-media-file') do
        xml.tag!("url", s3_path)
        xml.tag!("width", 1280)
        xml.tag!("height", 720)
        xml.tag!("size", 9842956)
        xml.tag!("duration", 10005)
        xml.tag!("cost", 1638)
      end
      xml.tag!('output-media-file') do
        xml.tag!("url", output_path)
        xml.tag!("width", 1280)
        xml.tag!("height", 720)
        xml.tag!("size", 9842956)
        xml.tag!("duration", 10005)
        xml.tag!("cost", 1638)
      end
      xml.tag!('watermark-file') do
        xml.tag!("url", "somepath to watermark")
        xml.tag!("size", 1024)
        xml.tag!("cost", 10)
      end
    end
    out_string
  end

  private

  def output_path
    's3://' + APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET] + '/' + self.s3_key + ".flv"
  end

  def thumbnail_path
    's3://' + APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET] + "/" + self.id.to_s
  end

  def set_status_and_format
    self.status = VIDEO_STATUS_PENDING
    self.format = 'Flash'
  end

  def record_status_change_create
    self.video_status_changes.build(:to_status => self.status)
  end
end