namespace :flix do
  desc "Simulate a flix cloud response to associate a video with it's S3 output file"
  task :repair => :environment do
    for lesson in Lesson.find(:all, :conditions => ["state != ? and conversion_started_at is not null",
                                                    LESSON_STATE_READY])
      puts "Found lesson ##{lesson.id}: #{lesson.title} (state: #{lesson.state})"
      s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                                       APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
      bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET])
      path = "videos/" + lesson.id.to_s + "/" + lesson.video_file_name + ".flv"
      key = bucket.key(path, true)
      if key.exists?
        print "   File exists..."
        job = FlixCloud::Notification.new(lesson.build_flix_response)
        lesson.finish_conversion(job)
        puts "and updated to ready state"
      else
        puts "   File not converted...skipping"
      end
    end
  end
end