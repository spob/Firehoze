class Activity < ActiveRecord::Base
  belongs_to :trackable, :polymorphic => true
  belongs_to :actor_user, :class_name => "User", :foreign_key => "actor_user_id"
  belongs_to :actee_user, :class_name => "User", :foreign_key => "actee_user_id"
  validates_presence_of :actor_user, :acted_upon_at

  def self.compile
    Lesson.activity_compiled_at_null(:lock => true).each do |lesson|
      Lesson.transaction do
        lesson.compile_activity
      end
    end
  end
end
