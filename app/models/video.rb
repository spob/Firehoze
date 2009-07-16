class Video < ActiveRecord::Base
  belongs_to :lesson

  # Allow flixcloud to view the raw video
  def grant_s3_permissions_to_flix
    set_url
    #change_state(LESSON_STATE_SET_S3_PERMISSIONS)
    s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],          
                                     APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
    bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_INPUT_VIDEO_BUCKET])
    file = bucket.key(self.s3_key, true)
    grantee = RightAws::S3::Grantee.new(bucket, FLIX_CLOUD_AWS_ID, 'READ', :apply)
    grantee = RightAws::S3::Grantee.new(file, FLIX_CLOUD_AWS_ID, 'READ', :apply)
  end
end
