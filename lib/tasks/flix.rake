namespace :flix do
  desc "Simulate a flix cloud response to associate a video with it's S3 output file"
  task :repair => :environment do
    for video in ProcessedVideo.find(:all, :conditions => ["status = ? and conversion_started_at is not null",
                                                    'Converting'])
      puts "Found video ##{video.id}: #{video.lesson.title} (state: #{video.status})"
      s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                                       APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
      bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET])
      #path = "videos/" + video.id.to_s + "/" + video.video_file_name + ".flv"
      key = bucket.key(video.s3_key, true)
      if key.exists?
        print "   File exists..."
        job = FlixCloud::Notification.new(video.build_flix_response)
        video.finish_conversion(job)
        puts "and updated to ready state"
      else
        puts "   File not converted...skipping"
      end
    end
  end
end