class GroupLesson < ActiveRecord::Base
  validates_presence_of :user, :lesson, :group
  belongs_to :user
  belongs_to :lesson
  belongs_to :group

  named_scope :active, :conditions => { :active => true}
end
