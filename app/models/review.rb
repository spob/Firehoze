class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :lesson, :counter_cache => true
  validates_presence_of :user, :title, :body, :lesson
  validates_uniqueness_of :user_id, :scope => :lesson_id
  validates_length_of :title, :maximum => 100, :allow_nil => true     

# Basic paginated listing finder
  def self.list(lesson, page)
    paginate :page => page, :conditions => { :lesson_id => lesson }, :order => 'id desc',
             :per_page => Constants::ROWS_PER_PAGE
  end

  # The review can be edited by a moderator
  def can_edit? user
    user.is_moderator?
  end
end
