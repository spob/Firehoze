class TopicComment < Comment
  belongs_to :topic, :counter_cache => true
  has_many :activities, :as => :trackable, :dependent => :destroy
  validates_presence_of :topic
  has_many :flags, :as => :flaggable, :dependent => :destroy
  has_many :flags, :as => :flaggable, :dependent => :destroy

  named_scope :include_user, :include => [:user]
  after_create :update_topic
  
  @@flag_reasons = [
          FLAG_LEWD,
          FLAG_SPAM,
          FLAG_OFFENSIVE,
          FLAG_DANGEROUS,
          FLAG_OTHER ]

  def self.flag_reasons
    @@flag_reasons
  end

  def compile_activity
    self.activities.create!(:actor_user => self.user,
                            :actee_user => self.topic.group.owner,
                            :acted_upon_at => self.created_at,
                            :group => self.topic.group,
                            :activity_string => 'topic_comment.activity',
                            :activity_object_id => self.topic.id,
                            :activity_object_class => self.topic.class.to_s,
                            :activity_object_human_identifier => self.topic.title,
                            :secondary_activity_object_id => self.topic.group.id,
                            :secondary_activity_object_human_identifier => self.topic.group.name,
                            :secondary_activity_object_class => self.topic.group.class.to_s)
    self.update_attribute(:activity_compiled_at, Time.now)
  end

  def last_public_comment?
    self == self.topic.last_public_topic_comment
  end

  def can_edit? user
    super or
            ((self.topic.group.moderated_by?(user) or self.topic.group.owned_by?(user)) and (self.public or Comment.show_public_private_option?(user)))
  end

  def self.notify_members comment__id
    comment = TopicComment.find(comment__id)
    comment.topic.group.member_users.each do |u|
      Notifier.deliver_new_topic_comment(comment, u)
    end
  end

  private

  def update_topic
    topic = self.topic
    topic.reload
    topic.update_attribute(:last_commented_at, self.created_at)
  end
end
