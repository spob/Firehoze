class Topic < ActiveRecord::Base
  # Can't use friendly id because title isn't unique
  has_friendly_id :title, :use_slug => true

  belongs_to :user
  belongs_to :group
  has_many :topic_comments
  validates_presence_of :user, :group, :title
  validates_length_of :title, :maximum => 200
  validates_uniqueness_of :title, :scope => :group_id

  # Temporary field used to store initial comments when creating a topic
  attr_accessor :comments
end
