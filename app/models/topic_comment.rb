class TopicComment < Comment
  belongs_to :topic, :counter_cache => true
  has_many :activities, :as => :trackable, :dependent => :destroy
  validates_presence_of :topic
  has_many :flags, :as => :flaggable, :dependent => :destroy
  after_create :update_topic

  # Display the option of public versus private to the user
  def self.show_public_private_option?(user)
    return false unless user
    user.is_admin? or user.is_moderator?
  end

  def compile_activity
    self.activities.create!(:actor_user => self.user,
                            :actee_user => self.topic.group.owner,
                            :acted_upon_at => self.created_at)
    self.update_attribute(:activity_compiled_at, Time.now)
  end

  private

  def update_topic
    self.topic.update_attribute(:last_commented_at, self.created_at)
  end
end
