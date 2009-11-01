class Topic < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_many :topic_comments
  validates_presence_of :user, :group, :title
  validates_length_of :title, :maximum => 200
end
