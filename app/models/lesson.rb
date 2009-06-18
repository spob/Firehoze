# A lesson includes a video, descriptive information and other meta data
class Lesson < ActiveRecord::Base
  belongs_to :instructor, :class_name => "User", :foreign_key => "instructor_id"
  has_many :reviews
  validates_presence_of :instructor, :title, :video_file_name
  validates_length_of :title, :maximum => 50, :allow_nil => true
  validates_numericality_of :video_file_size, :greater_than => 0, :allow_nil => true
  has_attached_file :video,
                    :url => "/assets/videos/:id/:basename.:extension",
                    :path => ":rails_root/public/assets/videos/:id/:basename.:extension"

  validates_attachment_presence :video
  validates_attachment_size :video, :less_than => APP_CONFIG['max_video_size'].megabytes
  validates_attachment_content_type :video, :content_type => ["application/x-shockwave-flash"]

# Basic paginated listing finder
  def self.list(page)
    paginate :page => page, :order => 'title',
             :per_page => Constants::ROWS_PER_PAGE
  end

  # The lesson can be added by an admin or the instructor who created it
  def can_edit? user
    user.is_admin? or instructor == user
  end
end
