# A lesson includes a video, descriptive information and other meta data
class Lesson < ActiveRecord::Base
  belongs_to :instructor, :class_name => "User", :foreign_key => "instructor_id"
  has_many :reviews
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

  ############## Start of definition of the state machine ##################
  acts_as_state_machine :initial => :pending
  state :pending
  state :updated_permissions
  state :converting
  state :ready
  state :failed

  event :set_permissions do
    transitions :from => :pending, :to => :updated_permissions
    transitions :from => :failed, :to => :updated_permissions
  end

  event :start_conversion do
    transitions :from => :updated_permissions, :to => :converting
  end

  event :finish_conversion do
    transitions :from => :converting, :to => :ready
  end

  event :fail do
    transitions :from => :pending, :to => :failed
    transitions :from => :updated_permissions, :to => :failed
    transitions :from => :converting, :to => :failed
  end
  ############## End of definition of the state machine ##################

# Basic paginated listing finder
  def self.list(page)
    paginate :page => page, :order => 'title',
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

  def set_s3_permissions
    s3_connection = RightAws::S3.new(APP_CONFIG[Constants::CONFIG_AWS_ACCESS_KEY_ID],
                                     APP_CONFIG[Constants::CONFIG_AWS_SECRET_ACCESS_KEY])
    bucket = s3_connection.bucket(APP_CONFIG[Constants::CONFIG_AWS_S3_INPUT_VIDEO_BUCKET])
    file = bucket.key(self.video.path, true)
    grantee = RightAws::S3::Grantee.new(bucket, Constants::FLIX_CLOUD_AWS_ID, 'READ', :apply)
    grantee = RightAws::S3::Grantee.new(file, Constants::FLIX_CLOUD_AWS_ID, 'READ', :apply)
  end

  def convert
    puts "input path: #{input_path}"
    puts "output path: #{output_path}"
    puts "watermark: #{Constants::WATERMARK_URL}"
    job = FlixCloud::Job.new(:api_key => Constants::FLIX_API_KEY,
                             :recipe_id => Constants::FLIX_RECIPE_ID,
                             :input_url => input_path,
                             :output_url => output_path,
                             :watermark_url => Constants::WATERMARK_URL,
                             :thumbnails_url => thumbnail_path)
    if job.save
      self.update_attributes(:flixcloud_job_id => job.id, :conversion_started_at => job.initialized_at)
    else
      msg = ""
      job.errors.each { |x| msg = (msg == "" ?  "" : ", ") + msg + x}
      raise msg
    end
  end

  def self.convert_video lesson_id
    lesson = Lesson.find(lesson_id)

    lesson.set_permissions!
    lesson.set_s3_permissions
    puts "setting permissions done"

    lesson.start_conversion!
    if lesson.convert
      puts "conversion started"
      lesson.start_conversion!
    else
      puts "conversion start failed"
      raise "Starting conversion failed"
    end

  rescue Exception => e
    Lesson.transaction do
      lesson.fail!
    end
    # rethrow the exception so we see the error in the periodic jobs log
    raise e
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
end
