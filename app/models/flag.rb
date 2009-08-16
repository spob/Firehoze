class Flag < ActiveRecord::Base
  before_validation_on_create :default_values
  belongs_to :flaggable, :polymorphic => true
  belongs_to :user
  belongs_to :moderator_user, :class_name => "User", :foreign_key => "moderator_user_id"
  validates_presence_of :user, :status, :reason_type, :comments
  validates_inclusion_of :status, :in => [ FLAG_STATUS_PENDING, FLAG_STATUS_RESOLVED,
                                           FLAG_STATUS_RESOLVED_MANUALLY, FLAG_STATUS_REJECTED ]

  attr_protected :status, :response

  named_scope   :pending, :conditions => {:status => FLAG_STATUS_PENDING }
  # Credits which have been warned to be about to expire
  named_scope :by_flaggable,
              lambda{ |flaggable| {:conditions => { :flaggable_type => flaggable.to_s } }
              }

  @@flag_statuses = [
          FLAG_STATUS_PENDING,
          FLAG_STATUS_RESOLVED,
          FLAG_STATUS_RESOLVED_MANUALLY,
          FLAG_STATUS_REJECTED ]

  def self.flag_statuses_select_list
    statuses = []
    for status in @@flag_statuses
      s = I18n.translate("flag.action_#{status}")
      statuses << [s, status]
    end
    statuses
  end

  def friendly_flagger_name
    if self.flaggable.class == Lesson
      return flaggable.title
    elsif self.flaggable.class == Review
      return flaggable.headline
    elsif self.flaggable.class == User
      return flaggable.login
    elsif self.flaggable.class == LessonComment
      return abbreviate(flaggable.body, 45)
    else
      return "ERROR: Unknown"
    end
  end

  def validate_on_create
    if Flag.find(:first, :conditions => { :flaggable_type => self.flaggable_type,
                                          :flaggable_id => self.flaggable_id,
                                          :user_id => self.user_id })
      errors.add_to_base I18n.t('flag.already_flagged')
    end
  end

  private

  def abbreviate str, len
    if str.length > len
      str[0..len] + "..."
    else
      str
    end
  end

  def default_values
    self.status = FLAG_STATUS_PENDING
  end
end
