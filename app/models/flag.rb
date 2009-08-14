class Flag < ActiveRecord::Base
  before_validation_on_create :default_values
  belongs_to :flaggable, :polymorphic => true
  belongs_to :user
  validates_presence_of :user, :status, :reason_type, :comments
  validates_inclusion_of :status, :in => [ FLAG_STATUS_PENDING, FLAG_STATUS_REMOVED, FLAG_STATUS_REMOVED_MANUALLY ]

  named_scope   :pending, :conditions => {:status => FLAG_STATUS_PENDING }

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

  def validate
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
