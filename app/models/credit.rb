# A credit can be redeemed to allow a user to download a video.
#
# A credit is considered available if it has not yet been redeemed, or used to
# view a video.
# Once a credit is redeemed, the redeemed_at field will be populated with the date when it
# was redeemed, and it will be associated to a lesson.
# A credit also stores information about when it was purchased (acquired_at), and the price
# for which is was purchased.
# The user is the user to whom this credit belongs.
#
# Redeemed credits represents a history of which videos have been purchased by which users.
class Credit < ActiveRecord::Base
  validates_presence_of     :user, :acquired_at, :price
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true

  belongs_to :sku, :class_name => "CreditSku"
  belongs_to :user
  belongs_to :lesson

  before_create :set_will_expire_at
  before_update :set_redeemed_at

  # Credits which have not yet been redeemed
  named_scope :available, :conditions => {:redeemed_at => nil, :expired_at => nil}

  # Credits which have not yet been warned to be about to expire
  named_scope :unwarned, :conditions => {:expiration_warning_issued_at => nil}

  # Credits which have been warned to be about to expire
  named_scope :warned,
              lambda{ |warned_before| {:conditions => ["expiration_warning_issued_at < ?",
                                                       warned_before] }
              }

  # Find credits which haven't been used in a long time and are about to expire. Specifically, look for credits
  # for which the associated user hasn't logged in to the system for a long time (e.g., a year) where the credits
  # are at least that old.
  # This named_scope will likely be chained with the available named scope
  named_scope :to_expire,
              lambda{ |expire_at| {:conditions => ["credits.will_expire_at < ?", expire_at ]}
              }

  # Expire credits that are older than a specified period of time for which the user who owns the credit hasn't logged
  # in to the account for that period of time as well.
  def self.expire_unused_credits
    warn_before_credit_expiration_days = APP_CONFIG['warn_before_credit_expiration_days'].to_i

    # Expire the credits that are about to expire
    Credit.available.to_expire(Time.zone.now).warned(
            warn_before_credit_expiration_days.days.ago).update_all(:expired_at => Time.zone.now)

    # Send a warning for those that are coming close
    # The inner query finds all credits about to expire and builds an array of user_ids from it, to pass to the second
    # one which searches for users.
    for user in User.active.find(:all,
                                 :conditions => ["id in (?)",
                                                 Credit.available.unwarned.to_expire(
                                                         warn_before_credit_expiration_days.days.since).scoped(
                                                         :select => "DISTINCT user_id").collect(&:user_id)])

      TaskServerLogger.instance.info("Expiration warning issued for user: #{user.login}")
      Credit.transaction do
        Notifier.deliver_credits_about_to_expire user
        user.credits.available.unwarned.to_expire(warn_before_credit_expiration_days.days.since).update_all(
                :expiration_warning_issued_at => Time.zone.now)
      end
    end
  end

  private

  def set_will_expire_at
    self.will_expire_at = APP_CONFIG['expire_credits_after_days'].to_i.days.since
  end

  def set_redeemed_at
    # Is the lesson set (indicating that the credit is being redeemed? If so, set the redeemed at date
    self.redeemed_at = Time.now if self.redeemed_at.nil? and !self.lesson.nil?
  end
end