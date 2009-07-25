# A lesson includes a video, descriptive information and other meta data
#
# The state field tracks the current state of the video in its workflow. The
# normal workflow is as follows:
#   pending:                  raw video was just uploaded. A periodic job will be triggered to
#           '                 start the conversion
#   converting:               file submitted to flixcloud for conversion
#   ready:                    video ready for viewing
#   failed:                   an error occurred at some point along the way
#
#   1.  You upload a video when you create a lesson. That goes into the Amazon S3 input bucket, and the lesson is in a
#       pending state. A periodic job is kicked off to convert the video.
#   2. When the periodic job runs, it will invoke a conversion to start. It grants read permissions on the videos to
#      flix cloud (they need to be able to see the videos in order to pull them and process them). It then uses a web
#      service call to tell flix cloud to start converting the video. 
#   3. Flix cloud will then asynchronously process the video. This usually takes between 2 and 5 minutes. FlixCloud
#      pulls the raw video down from the Amazon S3 location, transcodes it (converts it to flash, applies the
#      watermark), and uploads the finished result back to an output bucket on Amazon S3. It will also upload a
#      thumbnail image to a thumbnail bucket.
#   4. Now flix cloud must tell us that the video is ready for viewing. It does this buy accessing a special URL that
#      I've provided called conversion_notify. The URL for flixCloud to invoke is a configuration option defined in
#      flixcloud. Conversion notify updates the lesson with information such as the url of the output location, the
#      duration, the filesize, etc. It then sets the state to conversion_end_success.
#   5. Conversion notify then sets the state to calc_thumb_url_start and calculates the thumbnail url (which you can
#      use to display the thumbnail in an image tag). If that's successful, the lesson is ready for viewing and the
#      status is set to ready.
#
#   A couple of notes.
#
#    * Since flixcloud doesn't know about  your local dev machine, #4 is never invoked in your dev environment, so
#      the video will never be "ready". That's what the flix:repair rake task does. It says that the output video, if
#      it was successfully processes, should reside at a particular location in the Amazon S3 bucket. Does it? If so,
#      simulate the conversion_notify call. Not to do so, some of the info I populate (such as the duration) is bogus.
#    * Normal users shouldn't see lessons which are not in a ready state.
#    * admin's should see all lessons, their current state, and a complete history of all the states it's gone
#      through and when.
#    * The instructor should see lessons they've submitted regardless of state, but don't see the complete history.
#    * When the video is done processing, the instructor should get an email
#    * When a video conversion process fails at any point, it moves into a failed state. The instructor and the
#      admins get an email alerting them.
#    * In Step #2 above, when we trigger the conversion to start, I also create a periodic job that fires after a
#      set amount of time (an hour I think?). when that job wakes up, it checks to see if the video has completed
#      processing. If it hasn't, it will alert the admin via email that something may have gone wrong.
class Lesson < ActiveRecord::Base
  acts_as_taggable

  ajaxful_rateable :stars => 5
  cattr_reader :per_page
  @@per_page = LESSONS_PER_PAGE

  belongs_to :instructor, :class_name => "User", :foreign_key => "instructor_id"
  has_many :reviews
  has_many :video_status_changes, :order => "id"
  has_many :credits
  has_many :comments, :class_name => "LessonComment"
  has_many :free_credits, :order => "id"
  has_many :videos
  has_many :processed_videos, :order => "id"
  has_many :lesson_buy_patterns, :order => "counter DESC"
  has_one  :original_video
  validates_presence_of :instructor, :title, :status, :synopsis
  validates_length_of :title, :maximum => 50, :allow_nil => true
  validates_length_of :synopsis, :maximum => 500, :allow_nil => true

  # Used to seed the number of free downloads available
  attr_accessor :initial_free_download_count

  before_validation_on_create :set_status_on_create
  after_create  :create_free_credits

  named_scope   :most_popular, :order => "credits_count DESC"
  named_scope   :highest_rated, :order => "rating_average DESC"
  named_scope   :newest, :order => "created_at DESC"
  named_scope   :ready, :conditions => {:status => VIDEO_STATUS_READY }
  named_scope   :pending, :conditions => {:status => VIDEO_STATUS_PENDING }
  named_scope   :failed, :conditions => {:status => VIDEO_STATUS_FAILED }

  # Basic paginated listing finder
  # if the user is specified and is an admin, then lessons will be retrieved regardless of
  # the state of the video. Otherwise, only READY videos will be retrieved
  def self.list(page, user=nil)
    conditions = {}
    conditions = ["status = ? or instructor_id = ?",
                  VIDEO_STATUS_READY, user]  unless (user and user.try(:is_admin?))
    paginate :page => page,
             :conditions => conditions,
             :order => 'id desc',
             :per_page => per_page
  end

  def ready?
    self.status == VIDEO_STATUS_READY
  end

  def owned_by?(user)
    !self.credits.scoped_by_user_id(user).first.nil?
  end

  def instructed_by?(user)
    instructor == user
  end

  # The lesson can be edited by an admin or the instructor who created it
  def can_edit? user
    user and (user.is_admin? or user.is_moderator? or instructor == user)
  end

  # Has this user reviewed this lesson already?
  def reviewed_by? user
    !Review.scoped_by_user_id(user).scoped_by_lesson_id(self).empty?
  end

  # Create a periodic job to trigger a conversion in the background
  def trigger_conversion
    RunOncePeriodicJob.create!(:name => 'ConvertVideo',
                               :job => "OriginalVideo.convert_video #{self.original_video.id}")
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
  
  def output_url
    "http://#{APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET]}.s3.amazonaws.com/#{self.video.path}.flv"
  end

  def total_buy_pattern_counts
    self.lesson_buy_patterns.inject(0) {|sum, item| sum + item.counter}
  end

  private

  Tag.destroy_unused = true

  def input_path
    #'s3://' + APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET] + '/' + self.video.path
  end

  def output_path
    #'s3://' + APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET] + '/' + self.video.path + ".flv"
  end

  def thumbnail_path
    #'s3://' + APP_CONFIG[CONFIG_AWS_S3_THUMBS_BUCKET] + "/" + self.id.to_s
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

  def s3_connect()
    RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                     APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
  end

  def set_status_on_create
    self.status = VIDEO_STATUS_PENDING
  end
end