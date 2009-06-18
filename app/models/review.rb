class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :lesson
  validates_presence_of :user, :title, :body, :lesson
  validates_uniqueness_of :user_id, :scope => :lesson_id
  validates_length_of :title, :maximum => 100, :allow_nil => true
end
