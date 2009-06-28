# A lesson includes a video, descriptive information and other meta data
class Lesson < ActiveRecord::Base
  belongs_to :instructor, :class_name => "User", :foreign_key => "instructor_id"
  has_many :reviews
  has_many :lesson_state_changes, :order => "id"
  validates_presence_of :instructor, :title, :video_file_name, :state
  validates_length_of :title, :maximum => 50, :allow_nil => true
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true
  has_attached_file :video,
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    #:s3_permissions => 'public',
                    # TODO: This should be private but I'm making it public until I can get the S3 permissions working'
                    :s3_permissions => 'private',
                    :path => ":attachment/:id/:basename.:extension",
                    #:bucket => "input.firehoze.com"
                    :bucket => APP_CONFIG[Constants::CONFIG_AWS_S3_INPUT_VIDEO_BUCKET]
  #:url => "/assets/videos/:id/:basename.:extension",
  #:path => ":rails_root/public/assets/videos/:id/:basename.:extension"

  validates_attachment_presence :video
  validates_attachment_size :video, :less_than => APP_CONFIG[Constants::CONFIG_MAX_VIDEO_SIZE].megabytes
  validates_attachment_content_type :video, :content_type => ["application/x-shockwave-flash",
                                                              'application/x-swf',
                                                              'video/x-msvideo',
                                                              'video/avi',
                                                              'video/quicktime',
                                                              'video/3gpp',
                                                              'video/x-ms-wmv',
                                                              'video/mp4',
                                                              'video/mpeg']


  # Used to record a messgage for the state change
  attr_accessor :state_change_message

  before_create :record_state_change_create
  before_update :record_state_change_update

# Basic paginated listing finder
  def self.list(page, view_all=false)
    conditions = {}
    conditions = { :state => Constants::LESSON_STATE_READY } unless view_all
    paginate :page => page,
             :conditions => conditions,
             :order => 'id desc',
             :per_page => Constants::ROWS_PER_PAGE
  end

  # The lesson can be edited by an admin or the instructor who created it
  def can_edit? user
    user and (user.is_admin? or user.is_moderator? or instructor == user)
  end

  # Has this user reviewed this lesson already?
  def reviewed_by? user
    !Review.scoped_by_user_id(user).scoped_by_lesson_id(self).empty?
  end

  def finish_conversion job
    if job.successful?
      job.update_attributes(
              :conversion_ended_at => job.finished_job_at,
              :finished_video_file_location => job.output_media_file.url,
              :finished_video_width => job.output_media_file.width,
              :finished_video_height => job.output_media_file.height,
              :finished_video_file_size => job.output_media_file.size,
              :finished_video_duration => job.output_media_file.duration,
              :finished_video_cost => job.output_media_file.cost,
              :input_video_cost => job.input_media_file.cost)
      change_state(Constants::LESSON_STATE_READY, I18n.t('lesson.ready'))
    else
      change_state(Constants::LESSON_STATE_FAILED, job.error_message)
    end
    job.successful?
  rescue Exception => e
    change_state(Constants::LESSON_STATE_FAILED, 'failed: ' + e.message)
    raise e
  end

  def change_state(new_state, msg = nil)
    self.update_attributes(:state => new_state,
                           :state_change_message => msg)
  end

  def self.convert_video lesson_id
    lesson = Lesson.find(lesson_id)

    lesson.set_s3_permissions
    unless lesson.convert
      raise "Starting conversion failed"
    end

  rescue Exception => e
    Lesson.transaction do
      lesson.change_state(Constants::LESSON_STATE_FAILED, 'failed: ' + e.message)
    end
    # rethrow the exception so we see the error in the periodic jobs log
    raise e
  end

  def set_s3_permissions
    change_state(Constants::LESSON_STATE_SET_S3_PERMISSIONS, I18n.t('lesson.S3_permissions_start'))
    s3_connection = RightAws::S3.new(APP_CONFIG[Constants::CONFIG_AWS_ACCESS_KEY_ID],
                                     APP_CONFIG[Constants::CONFIG_AWS_SECRET_ACCESS_KEY])
    bucket = s3_connection.bucket(APP_CONFIG[Constants::CONFIG_AWS_S3_INPUT_VIDEO_BUCKET])
    file = bucket.key(self.video.path, true)
    grantee = RightAws::S3::Grantee.new(bucket, Constants::FLIX_CLOUD_AWS_ID, 'READ', :apply)
    grantee = RightAws::S3::Grantee.new(file, Constants::FLIX_CLOUD_AWS_ID, 'READ', :apply)
    change_state(Constants::LESSON_STATE_SET_S3_PERMISSIONS_SUCCESS, I18n.t('lesson.S3_permissions_end'))
  end

  def convert
    change_state(Constants::LESSON_STATE_START_CONVERSION, I18n.t('lesson.conversion_start'))
    job = FlixCloud::Job.new(:api_key => Constants::FLIX_API_KEY,
                             :recipe_id => Constants::FLIX_RECIPE_ID,
                             :input_url => input_path,
                             :output_url => output_path,
                             :watermark_url => Constants::WATERMARK_URL,
                             :thumbnails_url => thumbnail_path)
    if job.save
      change_state(Constants::LESSON_STATE_START_CONVERSION_SUCCESS, I18n.t('lesson.conversion_end'))
      self.update_attributes(:flixcloud_job_id => job.id, :conversion_started_at => job.initialized_at)
    else
      msg = ""
      job.errors.each { |x| msg = (msg == "" ?  "" : ", ") + msg + x}
      raise msg
    end
  end

  private

  def output_path
    's3://' + APP_CONFIG[Constants::CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET] + '/' + self.video.path
  end

  def input_path
    's3://' + APP_CONFIG[Constants::CONFIG_AWS_S3_INPUT_VIDEO_BUCKET] + '/' + self.video.path
  end

  def thumbnail_path
    's3://' + APP_CONFIG[Constants::CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET] + "/thumbs/" + self.id.to_s
  end

  def record_state_change_create
    self.state_change_message = nil
    self.state = Constants::LESSON_STATE_PENDING
    self.lesson_state_changes.build(:to_state => self.state,
                                    :message =>  I18n.t('lesson.created'))
  end

  def record_state_change_update
    if self.state_changed? or self.new_record?
      self.lesson_state_changes.build(:from_state => self.state_was,
                                      :to_state => self.state,
                                      :message =>  self.state_change_message)

      self.state_change_message = nil
    end
  end
end