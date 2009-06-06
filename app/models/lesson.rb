class Lesson < ActiveRecord::Base
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  validates_presence_of :author, :title
  validates_length_of :title, :maximum => 50, :allow_nil => true
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true
#  acts_as_authorizable
  has_attached_file :video,
          :url => "/assets/videos/:id/:basename.:extension",
          :path => ":rails_root/public/assets/videos/:id/:basename.:extension"

  validates_attachment_presence :video
  validates_attachment_size :video, :less_than => 500.megabytes
  validates_attachment_content_type :video, :content_type => ["application/x-shockwave-flash"]
  
  def self.list(page)
    paginate :page => page, :order => 'title',
            :per_page => Constants::ROWS_PER_PAGE
  end

  def can_edit? user
    user.is_admin? or author == user
  end
end
