class LessonAttachment < ActiveRecord::Base
  belongs_to :lesson, :counter_cache => :lesson_attachments_count
  validates_presence_of :attachment_file_name
  validates_presence_of :lesson, :title
  validates_numericality_of :attachment_file_size, :greater_than => 0, :allow_nil => true

  has_attached_file :attachment,
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :s3_permissions => 'public-read',
                    :path => "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/attachments/:attachment/:id/:style/:basename.:extension",
                    :bucket => APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]
  #:url => "/assets/videos/:id/:basename.:extension",
  #:path => ":rails_root/public/assets/videos/:id/:basename.:extension"

  validates_attachment_presence :attachment
  validates_attachment_size :attachment, :less_than => APP_CONFIG[CONFIG_MAX_ATTACHMENT_SIZE].megabytes
end