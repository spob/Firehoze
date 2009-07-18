class OriginalVideo < Video
  before_validation :set_status_and_format

  validates_presence_of :video_file_name
  validates_presence_of :lesson, :format, :status
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true
  has_attached_file :video,
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :s3_permissions => 'private',
                    :path => ":attachment/:id/:basename.:extension",
                    :bucket => APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET]
  #:url => "/assets/videos/:id/:basename.:extension",
  #:path => ":rails_root/public/assets/videos/:id/:basename.:extension"

  validates_attachment_presence :video
  validates_attachment_size :video, :less_than => APP_CONFIG[CONFIG_MAX_VIDEO_SIZE].megabytes
  validates_attachment_content_type :video, :content_type => ["application/x-shockwave-flash",
                                                              'application/x-swf',
                                                              'application/x-avi',
                                                              'video/x-msvideo',
                                                              'video/avi',
                                                              'video/quicktime',
                                                              'video/3gpp',
                                                              'video/x-ms-wmv',
                                                              'video/mp4',
                                                              'video/mpeg']

  def set_url
    self.update_attributes!(:s3_key => self.video.path,
                            :s3_path => "s3://#{APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET]}/#{self.video.path}",
                            :url => "http://#{APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET]}.s3.amazonaws.com/#{self.video.path}")
  end

  # Call out to flixcloud to trigger a conversion process
  def trigger_convert
    processed_video = ProcessedVideo.find(:first, :conditions => { :lesson_id => self.lesson, :format => VIDEO_FORMAT_FLASH })
    unless processed_video
      processed_video = ProcessedVideo.create!(:lesson_id => self.lesson.id,
                                               :video_file_name => self.video_file_name,
                                               :converted_from_video => self)
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
      video.lesson.update_attribute(:state, VIDEO_STATUS_FAILED)
    end
    # rethrow the exception so we see the error in the periodic jobs log
    raise e
  end

  private

  def set_status_and_format
    self.status = VIDEO_STATUS_READY
    self.format = VIDEO_FORMAT_ORIGINAL
    # for some reason paperclip is putting a // in the path...so replace it with one
  end
end