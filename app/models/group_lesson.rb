class GroupLesson < ActiveRecord::Base
  validates_presence_of :user, :lesson, :group
  belongs_to :user
  belongs_to :lesson
  belongs_to :group
  has_many :activities, :as => :trackable, :dependent => :destroy

  named_scope :active, :conditions => { :active => true}

  def compile_activity
    self.activities.create!(:actor_user => self.user,
                            :actee_user => self.group.owner,
                            :acted_upon_at => self.created_at,
                            :group => self.group,
                            :activity_object_id => self.group.id,
                            :activity_string => "group_lesson.activity",
                            :activity_object_human_identifier => self.group.name,
                            :activity_object_class => self.group.class.to_s,
                            :secondary_activity_object_id => self.lesson.id,
                            :secondary_activity_object_human_identifier => self.lesson.title,
                            :secondary_activity_object_class => self.lesson.class.to_s)
    self.update_attribute(:activity_compiled_at, Time.now)
  end
end
