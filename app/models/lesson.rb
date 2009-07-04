# A lesson includes a video, descriptive information and other meta data
#
# The state field tracks the current state of the video in its workflow. The
# normal workflow is as follows:
#   pending:                  raw video was just uploaded. A periodic job will be triggered to
#           '                 start the conversion
#   S3_permissions_start:     about to call out to Amazon S3 to set the permissions, granting
#                             flixcloud access to the file
#   trigger_conversion_start: about to call out to flixcloud to start the conversion process
#   trigger_conversion_end:   successfully triggered a conversion process to occur in flixcloud
#   conversion_end_success:   received notification from flixcloud that conversion successfully
#                             completed
#   calc_thumb_url_start:     about to parse the information returned from flixcloud to calculate,
#                             among other things, the thumbnail_url
#   ready:                    video ready for viewing
#   failed:                   an error occurred at some point along the way'
class Lesson < ActiveRecord::Base
  ajaxful_rateable :stars => 5
  belongs_to :instructor, :class_name => "User", :foreign_key => "instructor_id"
  has_many :reviews
  has_many :lesson_state_changes, :order => "id"
  has_many :credits
  has_many :free_credits, :order => "id"
  validates_presence_of :instructor, :title, :video_file_name, :state
  validates_length_of :title, :maximum => 50, :allow_nil => true
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
                                                              'video/x-msvideo',
                                                              'video/avi',
                                                              'video/quicktime',
                                                              'video/3gpp',
                                                              'video/x-ms-wmv',
                                                              'video/mp4',
                                                              'video/mpeg']


  # Used to record a messgage for the state change
  attr_accessor :state_change_message
  # Used to seed the number of free downloads available
  attr_accessor :initial_free_download_count

  before_create :record_state_change_create
  after_create  :create_free_credits
  before_update :record_state_change_update

  named_scope   :most_popular, :order => "credits_count DESC"
  named_scope   :highest_rated, :order => "rating_average DESC"
  named_scope   :newest, :order => "created_at DESC"
  named_scope   :pending, :conditions => {:state => LESSON_STATE_PENDING }
  named_scope   :ready, :conditions => {:state => LESSON_STATE_READY }
  named_scope   :failed, :conditions => {:state => LESSON_STATE_FAILED }

# Basic paginated listing finder
# if view_all is false, only videos in the ready state will be returned
  def self.list(page, user=nil)
    conditions = {}
    conditions = ["state = ? or instructor_id = ?",
                  LESSON_STATE_READY, user]  unless (user and user.try(:is_sysadmin?))
    paginate :page => page,
             :conditions => conditions,
             :order => 'id desc',
             :per_page => ROWS_PER_PAGE
  end

  def ready?
    self.state == LESSON_STATE_READY
  end

  def owned_by?(user)
    !self.credits.scoped_by_user_id(user).first.nil?
  end

  # The lesson can be edited by an admin or the instructor who created it
  def can_edit? user
    user and (user.is_admin? or user.is_moderator? or instructor == user)
  end

  # Has this user reviewed this lesson already?
  def reviewed_by? user
    !Review.scoped_by_user_id(user).scoped_by_lesson_id(self).empty?
  end

  # This method takes a job record populated from the flixcloud gem, and will update the various attributes
  # on the job accordingly.
  def finish_conversion job, set_permissions=true
    if job.successful?
      self.update_attributes(
              :conversion_ended_at => job.finished_job_at,
              :finished_video_file_location => job.output_media_file.url,
              :finished_video_width => job.output_media_file.width,
              :finished_video_height => job.output_media_file.height,
              :finished_video_file_size => job.output_media_file.size,
              :finished_video_duration => job.output_media_file.duration,
              :finished_video_cost => job.output_media_file.cost,
              :input_video_cost => job.input_media_file.cost)
      change_state(LESSON_STATE_END_CONVERSION, I18n.t('lesson.conversion_end_success') +
              " (##{job.id})")
      set_thumbnail_url
      change_state(LESSON_STATE_READY, I18n.t('lesson.ready'))
      Notifier.deliver_lesson_ready self
    else
      change_state(LESSON_STATE_FAILED, job.error_message)
      Notifier.deliver_lesson_processing_failed self
    end
    job.successful?
  rescue Exception => e
    change_state(LESSON_STATE_FAILED, 'failed: ' + e.message)
    raise e
  end

  def change_state(new_state, msg = nil)
    self.update_attributes(:state => new_state,
                           :state_change_message => msg)
  end

  # First call out to Amazon S3 to grant permissions to flixcloud to view the raw video,
  # then trigger a video conversion at flixcloud itself
  def self.convert_video lesson_id
    lesson = Lesson.find(lesson_id)

    lesson.grant_s3_permissions_to_flix
    unless lesson.convert
      raise "Starting conversion failed"
    end

  rescue Exception => e
    Lesson.transaction do
      lesson.change_state(LESSON_STATE_FAILED, 'failed: ' + e.message)
    end
    # rethrow the exception so we see the error in the periodic jobs log
    raise e
  end

  # Allow flixcloud to view the raw video
  def grant_s3_permissions_to_flix
    change_state(LESSON_STATE_SET_S3_PERMISSIONS, I18n.t('lesson.S3_permissions_start'))
    s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                                     APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
    bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET])
    file = bucket.key(self.video.path, true)
    grantee = RightAws::S3::Grantee.new(bucket, FLIX_CLOUD_AWS_ID, 'READ', :apply)
    grantee = RightAws::S3::Grantee.new(file, FLIX_CLOUD_AWS_ID, 'READ', :apply)
  end

  # Call out to flixcloud to trigger a conversion process
  def convert
    change_state(LESSON_STATE_START_CONVERSION, I18n.t('lesson.conversion_start'))
    job = FlixCloud::Job.new(:api_key => FLIX_API_KEY,
                             :recipe_id => FLIX_RECIPE_ID,
                             :input_url => input_path,
                             :output_url => output_path,
                             :watermark_url => WATERMARK_URL,
                             :thumbnails_url => thumbnail_path)
    if job.save
      change_state(LESSON_STATE_START_CONVERSION_SUCCESS, I18n.t('lesson.conversion_end') +
              " (##{job.id})")
      self.update_attributes(:flixcloud_job_id => job.id, :conversion_started_at => job.initialized_at)
      RunOncePeriodicJob.create!(:name => 'DetectZombieVideoProcess',
                                 :job => "Lesson.detect_zombie_video #{self.id}, #{job.id}",
                                 :next_run_at => (APP_CONFIG[CONFIG_ZOMBIE_VIDEO_PROCESS_MINUTES].to_i.minutes.from_now))
    else
      msg = ""
      job.errors.each { |x| msg = (msg == "" ?  "" : ", ") + msg + x}
      raise msg
    end
  end

  # Create a periodic job to trigger a conversion in the background
  def trigger_conversion
    RunOncePeriodicJob.create!(:name => 'ConvertVideo',
                               :job => "Lesson.convert_video #{self.id}")
  end

  def set_thumbnail_url
    change_state(LESSON_STATE_GET_THUMBNAIL_URL, I18n.t('lesson.calc_thumb_url_start'))
    #s3_connection = s3_connect
    #bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET])
    #file = bucket.key(thumbnail_path + "/thumb_0000.png", true)
    url = "http://" + APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET] +
            ".s3.amazonaws.com/" + id.to_s + "/thumb_0000.png"
    self.update_attribute(:thumbnail_url, url)
    #grantee = RightAws::S3::Grantee.new(bucket, FLIX_CLOUD_AWS_ID, 'READ', :apply)
    #grantee = RightAws::S3::Grantee.new(file, FLIX_CLOUD_AWS_ID, 'READ', :apply)
  end

  def consume_free_credit user
    free_credit = self.free_credits.available.first
    sku = CreditSku.find_by_sku!(FREE_CREDIT_SKU)
    if free_credit
      credit = Credit.create!(:sku => sku, :price => sku.price, :user => user,
                              :acquired_at => Time.zone.now, :lesson => self, :acquired_at => Time.now)
      free_credit.update_attributes!(:credit => credit, :redeemed_at => Time.now, :user => user)
    end
    free_credit
  end

  # Check if a video was submitted for processing and never returned. If so, send an email alert
  def self.detect_zombie_video(lesson_id, job_id)
    lesson = Lesson.find(lesson_id)
    if lesson.flixcloud_job_id == job_id
      # id is the same, so a new job hasn't been submitted
      if lesson.state == LESSON_STATE_START_CONVERSION_SUCCESS
        # still in a processing state
        Notifier.deliver_lesson_processing_hung lesson
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
        xml.tag!("url", input_path)
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


  def input_path
    's3://' + APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET] + '/' + self.video.path
  end

  def output_path
    's3://' + APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET] + '/' + self.video.path + ".flv"
  end

  def thumbnail_path
    's3://' + APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET] + "/" + self.id.to_s
  end

  def record_state_change_create
    self.state_change_message = nil
    self.state = LESSON_STATE_PENDING
    self.lesson_state_changes.build(:to_state => self.state,
                                    :message =>  I18n.t('lesson.pending'))
  end

  def create_free_credits
    if initial_free_download_count and initial_free_download_count > 0
      sku = CreditSku.find_by_sku!(FREE_CREDIT_SKU)

      initial_free_download_count.times do
        self.free_credits.create!
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    # test environment is not seeded with SKU's
    raise e unless ENV['RAILS_ENV'] == 'test'
  end

  def record_state_change_update
    if self.state_changed?
      self.lesson_state_changes.build(:from_state => self.state_was,
                                      :to_state => self.state,
                                      :message =>  self.state_change_message)

      self.state_change_message = nil
    end
  end

  def s3_connect()
    RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                     APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
  end
end