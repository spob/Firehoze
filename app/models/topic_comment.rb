class TopicComment < Comment
  belongs_to :topic
  validates_presence_of :topic
  has_many :flags, :as => :flaggable, :dependent => :destroy
end
