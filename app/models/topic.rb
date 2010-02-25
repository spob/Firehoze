class Topic < ActiveRecord::Base
  # Can't use friendly id because title isn't unique
  has_friendly_id :title, :use_slug => true

  belongs_to :user
  belongs_to :group
  delegate :name, :to => :group, :prefix => true
  has_many :topic_comments, :order => "id"
  has_one :last_topic_comment, :class_name => "TopicComment", :order => "id DESC"
  has_one :last_public_topic_comment, :class_name => "TopicComment", :conditions => { :public => true }, :order => "id DESC"
  validates_presence_of :user, :group, :title
  validates_presence_of :comments, :on => :create
  validates_length_of :title, :maximum => 200
  validates_uniqueness_of :title, :scope => :group_id

  # Temporary field used to store initial comments when creating a topic
  attr_accessor :comments

  def comments_user_sensitive(current_user)
    show_private = (current_user.try('is_an_admin?') or current_user.try('is_a_moderator?'))
    show_rejected = (group.moderated_by? current_user or group.owned_by? current_user or show_private)   
    if show_private
      if show_rejected
        self.topic_comments.include_user
      else
        self.topic_comments.ready.include_user
      end
    else
      if show_rejected
        self.topic_comments.public.include_user
      else
        self.topic_comments.public.ready.include_user
      end
    end
  end
end
