require 'net/ftp'

namespace :flix do
  desc "Simulate a flix cloud response to associate a video with it's S3 output file"
  task :repair => :environment do
    for video in Video.find(:all,
                            :conditions => ["status = ? and conversion_started_at is not null and s3_root_dir is not null",
                                            VIDEO_STATUS_CONVERTING])
      puts "Found video ##{video.id}: #{video.lesson.title} (state: #{video.status})"
      check_for_video(video)
    end
  end

  def check_for_video(video)
    s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                                     APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
    bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET])
    if video.type.eql?("FullProcessedVideo")
      key_path = "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/videos/#{video.id}/full.flv"
    elsif video.type.eql?("PreviewProcessedVideo")
      key_path = "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/videos/#{video.id}/preview.flv"
    end
    puts "Checking for file at #{key_path}"
    key = bucket.key(key_path, true)
    if key.exists?
      print "   File exists..."
      video.finish_conversion Zencoder::Job.details(video.flixcloud_job_id, :api_key => FLIX_API_KEY).body['job']
      puts "and updated to ready state"
    else
      puts "   File not converted...skipping"
    end
  end
end