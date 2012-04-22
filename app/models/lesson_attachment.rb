class LessonAttachment < ActiveRecord::Base
  belongs_to :lesson, :counter_cache => :lesson_attachments_count
  validates_presence_of :attachment_file_name
  validates_presence_of :lesson, :title
  validates_length_of :title, :maximum => 50, :allow_nil => true
  validates_numericality_of :attachment_file_size, :greater_than => 0, :allow_nil => true

  has_attached_file :attachment,
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                    :s3_permissions => 'public-read',
                    :path => "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/attachments/:attachment/:id/:style/:basename.:extension",
                    :bucket => APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]
  #:url => "/assets/videos/:id/:basename.:extension",
  #:path => ":rails_root/public/assets/videos/:id/:basename.:extension"

  validates_attachment_presence :attachment
  validates_attachment_size :attachment, :less_than => APP_CONFIG[CONFIG_MAX_ATTACHMENT_SIZE].megabytes
  validates_attachment_content_type :attachment, :content_type => [ 'image/gif', 'image/png', 'image/x-png',
                                                                    'image/jpeg', 'image/pjpeg', 'image/jpg',
                                                                    'image/tiff', 'image/bmp', 'image/x-xbitmap',
                                                                    "text/xml", "application/msword",
                                                                    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                                                                    "application/vnd.ms-powerpoint",
                                                                    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                                                                    "application/vnd.ms-excel",
                                                                    "application/vnd.oasis.opendocument.text",
                                                                    "application/vnd.oasis.opendocument.spreadsheet",
                                                                    "application/vnd.oasis.opendocument.graphics",
                                                                    "application/pdf",
                                                                    "application/vnd.oasis.opendocument.presentation",
                                                                    "application/octet-stream",
                                                                    "text/html", "text/plain",
                                                                    "application/pdf"]
end