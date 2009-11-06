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
                            :group => self.group)
    self.update_attribute(:activity_compiled_at, Time.now)
  end
end
