class ProcessedVideo < Video
  belongs_to :lesson, :counter_cache => true
  before_validation_on_create :set_video_status

  belongs_to :converted_from_video, :class_name => 'OriginalVideo'
  validates_presence_of :video_file_name
  validates_presence_of :lesson, :status
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true

  def update_processed_video_attributes
    self.update_attributes!(:s3_key => "#{self.s3_root_dir}/videos/#{self.id}/#{self.video_file_name}.flv",
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
                :conversion_ended_at => output_media_file['finished_at'],
                :video_width => output_media_file['width'],
                :video_height => output_media_file['height'],
                :video_file_size => output_media_file['file_size_bytes'],
                :video_duration => output_media_file['duration_in_ms'],
                :video_file_name => output_media_file['url'][/[^\/]*\z/],
                :video_content_type => 'application/x-flv',
                :processed_video_cost => 0, #zero_nvl(self.processed_video_cost) + job.output_media_file.cost.to_f,
                :input_video_cost => 0,
                :video_transcoding_error => nil,
                :thumbnail_url => (thumbnail_path),
                :s3_path => output_media_file['url'],
                :url => "http://#{APP_CONFIG[CONFIG_CDN_OUTPUT_SERVER]}/#{self.s3_key}")


        update_lesson_attributes(output_media_file['duration_in_ms'])

        self.change_status(VIDEO_STATUS_READY)
      else
        if output_media_file
          self.change_status(VIDEO_STATUS_FAILED, output_media_file['error_message'])
        else
          self.change_status(VIDEO_STATUS_FAILED, "Unable to find output_media_file for #{job['id']} #{self.class.name}")
        end
        Notifier.deliver_lesson_processing_failed self
      end
    end

    job.successful?
  rescue Exception => e
    self.change_status(VIDEO_STATUS_FAILED, ': ' + e.message)
    raise e
  end

  def change_status(new_status, msg=nil)
    self.video_status_changes.create!(:from_status => self.status,
                                      :to_status => new_status,
                                      :lesson => self.lesson,
                                      :message => msg)
    self.reload
    self.update_attributes!(:status => new_status,
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

# This is a utility method to build a dummy XML response message from flix cloud
  def build_flix_response
    xml = Builder::XmlMarkup.new(:target => out_string = "",
                                 :indent => 2)

    xml.instruct!(:xml, :encoding => "UTF-8")
    xml.job do
      xml.tag!("finished-job-at", Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"), :type => "datetime")
      xml.tag!("id", self.flixcloud_job_id.to_s, :type => "integer")
      xml.tag!("initialized-job-at", self.conversion_started_at.strftime("%Y-%m-%dT%H:%M:%SZ"), :type => "datetime")
      xml.tag!("recipe-name", "my-recipe")
      xml.tag!("recipe-id", FLIX_FULL_RECIPE_ID, :type => "integer")
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
        xml.tag!("url", output_ftp_path)
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

  def thumbnail_path(size=thumbnail_size)
    thumbnail = "http://#{APP_CONFIG[CONFIG_CDN_THUMBS_SERVER]}/#{self.s3_root_dir}/thumbs/#{lesson.id.to_s}/#{size}/thumb_0001.png"
  end

  def thumbnail_s3_path
    "s3://#{APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET]}/#{self.s3_root_dir}/thumbs/#{lesson.id.to_s}/#{thumbnail_size}"
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