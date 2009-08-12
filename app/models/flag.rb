class Flag < ActiveRecord::Base
  belongs_to :flaggable, :polymorphic => true
  belongs_to :user
  validates_presence_of :user, :status, :reason_type, :comments

  def friendly_flagger_name
    if self.flaggable.class.to_s == "Lesson"
      return flaggable.title
    elsif self.flaggable.class.to_s == "Review"
      return flaggable.headline
    elsif self.flaggable.class.to_s == "LessonComment"
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
end
