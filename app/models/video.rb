class Video < ActiveRecord::Base
  belongs_to :lesson
  has_many :video_status_changes, :order => "id"
  after_create :record_status_change_create

  # Allow flixcloud to view the raw video
  def grant_s3_permissions_to_flix
    set_url
    s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],          
                                     APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
    bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET])
    file = bucket.key(self.s3_key, true)
    grantee = RightAws::S3::Grantee.new(bucket, FLIX_CLOUD_AWS_ID, 'READ', :apply)
    grantee = RightAws::S3::Grantee.new(file, FLIX_CLOUD_AWS_ID, 'READ', :apply)
  end

  private
  
  def record_status_change_create
    self.video_status_changes.create!(:to_status => self.status, :lesson => self.lesson)
  end
end
