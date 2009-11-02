class TopicComment < Comment
  belongs_to :topic, :counter_cache => true
  validates_presence_of :topic
  has_many :flags, :as => :flaggable, :dependent => :destroy
  after_create :update_topic

  private

  def update_topic
    self.topic.update_attribute(:last_commented_at, self.created_at)
  end
end
