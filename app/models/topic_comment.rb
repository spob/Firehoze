class TopicComment < Comment
  belongs_to :topic, :counter_cache => true
  has_many :activities, :as => :trackable, :dependent => :destroy
  validates_presence_of :topic
  has_many :flags, :as => :flaggable, :dependent => :destroy
  after_create :update_topic

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

  private

  def update_topic
    self.topic.update_attribute(:last_commented_at, self.created_at)
  end
end
