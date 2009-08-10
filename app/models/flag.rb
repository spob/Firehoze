class Flag < ActiveRecord::Base
  belongs_to :flaggable, :polymorphic => true
  belongs_to :user
  validates_presence_of :user, :status , :reason_type, :comments
  
  def friendly_flagger_name
    flaggable.title if self.flaggable.class.to_s == "Lesson"
  end
end
