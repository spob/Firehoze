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
  has_many :reviews, :dependent => :destroy
  has_many :video_status_changes, :order => "id", :dependent => :destroy
  has_many :credits, :dependent => :destroy
  has_many :comments, :class_name => "LessonComment", :order => "id", :dependent => :destroy
  # there seems to be a mysql bug. See http://forums.mysql.com/read.php?20,276313,276313#msg-276313
  # so for now, I'm going to hand code this as a method'
  #has_one  :last_comment, :class_name => "LessonComment", :order => "id DESC"
  #has_one  :last_public_comment, :class_name => "LessonComment",
  #         :conditions => { :public => true }, :order => "id DESC"
  has_many :free_credits, :order => "id", :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :processed_videos, :order => "id"
  has_many :lesson_buy_patterns, :order => "counter DESC", :dependent => :destroy
  has_many :lesson_buy_pairs, :order => "counter DESC", :dependent => :destroy
  has_many :flags, :as => :flaggable, :dependent => :destroy
  has_many :rates, :as => :rateable, :dependent => :destroy
  has_one  :original_video
  has_one  :full_processed_video
  has_one  :preview_processed_video
  has_and_belongs_to_many :lesson_wishers, :join_table => 'wishes', :class_name => 'User'
  validates_presence_of :instructor, :title, :status, :synopsis
  validates_length_of :title, :maximum => 50, :allow_nil => true
  validates_length_of :synopsis, :maximum => 500, :allow_nil => true

  # Used to seed the number of free downloads available
  attr_accessor :initial_free_download_count
  attr_protected :status

  before_validation_on_create :set_status_on_create
  after_create  :create_free_credits

  # I added the id to the sort criteria so that the videos would be sorted in the same order every time, even in the
  # event of a tie in the primary sort criteria RBS
  named_scope   :most_popular, :order => "credits_count DESC, id DESC"
  named_scope   :highest_rated, :order => "rating_average DESC, id DESC"
  named_scope   :newest, :order => "id DESC"
  named_scope   :ready, :conditions => {:status => LESSON_STATUS_READY }
  named_scope   :pending, :conditions => {:status => LESSON_STATUS_PENDING }
  named_scope   :failed, :conditions => {:status => LESSON_STATUS_FAILED }
  named_scope   :rejected, :conditions => {:status => LESSON_STATUS_REJECTED }
  # Credits which have been warned to be about to expire
  # Note...add -1 to lesson collection to ensure that never that case where it will return NULL 
  named_scope :not_owned_by,
              lambda{ |user| { :conditions => ["lessons.id not in (?)", user.lessons.collect(&:id) + [-1]] }
              }

  @@lesson_statuses = [
          LESSON_STATUS_PENDING,
          LESSON_STATUS_CONVERTING,
          LESSON_STATUS_FAILED,
          LESSON_STATUS_READY,
          LESSON_STATUS_REJECTED ]

  @@flag_reasons = [
          FLAG_LEWD,
          FLAG_SPAM,
          FLAG_OFFENSIVE,
          FLAG_DANGEROUS,
          FLAG_IP ]

  def self.flag_reasons
    @@flag_reasons
  end

  def self.lesson_statuses
    @@lesson_statuses
  end

  def self.lesson_recommendations(user, limit=5)
    sql = <<END
      SELECT l.* FROM lessons AS l
      WHERE status = ?
        AND l.instructor_id <> ?
        AND EXISTS (
            SELECT null
            FROM lesson_buy_pairs AS pairs
            WHERE l.id = pairs.lesson_id)
        AND NOT EXISTS (
            SELECT null
            FROM credits
            WHERE user_id = ?
            AND lesson_id = l.id)
            ORDER BY l.rating_average DESC
      LIMIT ?
END
    lessons1 = Lesson.ready.find_by_sql([sql, VIDEO_STATUS_READY, user.id, user.id, limit])
    lessons2 = []
    tmp_limit = limit * 2 - lessons1.size
    lessons2 = Lesson.ready.find(:all, :conditions => ["instructor_id <> ? and id not in (?) and id not in (?)",
                                                       user.id,
                                                       lessons1.collect(&:id) + [-1],
                                                       user.lessons.collect(&:id) + [-1]],
                                 :limit => tmp_limit,
                                 :order => "rating_average DESC")
    all = lessons1 + lessons2
    lessons = []
    (1..limit).each do |i|
      lessons << all.delete(all.at(rand(all.size)))
    end
    lessons.find_all{|l| l}
  end

  # Call it vlast (as in very last) as opposed to last to differentiate it from the dynamic finder
  def vlast_comment
    kludge_workaround_for_f__cking_db_bug(comments)
  end

  # Call it vlast (as in very last) as opposed to last to differentiate it from the dynamic finder
  def vlast_public_comment
    kludge_workaround_for_f__cking_db_bug(comments.public)
  end

  # Basic paginated listing finder
  # if the user is specified and is an admin, then lessons will be retrieved regardless of
  # the state of the video. Otherwise, only READY videos will be retrieved
  def self.list(page, user=nil, lessons_per_page=per_page)
    conditions = {}
    conditions = ["status = ? or instructor_id = ?",
                  LESSON_STATUS_READY, user]  unless (user and user.try(:is_admin?))
    paginate :page => page,
             :conditions => conditions,
             :order => 'id desc',
             :per_page => lessons_per_page
  end

  def ready?
    self.status == LESSON_STATUS_READY
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

  def has_free_credits?
    free_credits.available.size > 0
  end

  # Create a periodic job to trigger a conversion in the background
  def trigger_conversion notify_url
    RunOncePeriodicJob.create!(:name => 'ConvertVideo',
                               :job => "OriginalVideo.convert_video #{self.original_video.id}, '#{notify_url}'")
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

  #def output_url
  #  "http://#{APP_CONFIG[CONFIG_CDN_SERVER]}/#{self.video.path}.flv"
  #end

  def total_buy_pattern_counts
    self.lesson_buy_patterns.inject(0) {|sum, item| sum + item.counter}
  end

  def update_status(unreject=false)
    if self.status == LESSON_STATUS_REJECTED and !unreject
      # do nothing...moderator put it in this status for a reason
    elsif any_video_match_by_status(VIDEO_STATUS_FAILED)
      update_status_attribute(LESSON_STATUS_FAILED)
    elsif videos.find_all{|video| video.class == FullProcessedVideo or video.class == PreviewProcessedVideo }.empty? or
            all_videos_match_by_status(VIDEO_STATUS_PENDING)
      update_status_attribute(LESSON_STATUS_PENDING)
    elsif any_video_match_by_status(LESSON_STATUS_CONVERTING)
      update_status_attribute(LESSON_STATUS_CONVERTING)
    elsif all_videos_match_by_status(LESSON_STATUS_READY)
      update_status_attribute(LESSON_STATUS_READY)
      Notifier.deliver_lesson_ready(self)
    else
      update_status_attribute("Unknown status")
    end
  end

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def reject
    self.status = LESSON_STATUS_REJECTED
  end

  def sized_thumbnail_url(size=:large)
    self.thumbnail_rule.gsub(/<size>/, size.to_s)
  end

  private

  Tag.destroy_unused = true

  def update_status_attribute(status)
    self.update_attribute(:status, status)
  end

  def any_video_match_by_status(status)
    videos.find_all{|video| video.class == FullProcessedVideo or video.class == PreviewProcessedVideo }.each do |video|
      return true if video.status == status
    end
    return false
  end

  def all_videos_match_by_status(status)
    videos.find_all{|video| video.class == FullProcessedVideo or video.class == PreviewProcessedVideo }.each do |video|
      return false if video.status != status
    end
    return true
  end

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

  def kludge_workaround_for_f__cking_db_bug c
    # do this as a two stepper to avoid http://forums.mysql.com/read.php?20,276313,276313#msg-276313
    # doing it this way avoids the limit bug in the database
    if c.empty?
      nil
    else
      c.at(c.size - 1)
    end
  end
end
