require 'net/ftp'

namespace :flix do
  desc "Simulate a flix cloud response to associate a video with it's S3 output file"
  task :repair => :environment do
    ftp = Net::FTP.new(APP_CONFIG[CONFIG_FTP_CDN_PATH])
    ftp.login(user = APP_CONFIG[CONFIG_FTP_CDN_USER], passwd = APP_CONFIG[CONFIG_FTP_CDN_PASSWORD])

    for video in Video.find(:all,
                                     :conditions => ["status = ? and conversion_started_at is not null and s3_root_dir is not null",
                                                     VIDEO_STATUS_CONVERTING])
      puts "Found video ##{video.id}: #{video.lesson.title} (state: #{video.status})"
      ftp.chdir('/')
      ftp.chdir(video.s3_root_dir)
      ftp.chdir("videos")
      files = ftp.nlst
      check_for_video(files, video)

      ftp.chdir('/')
      ftp.chdir(video.s3_root_dir)
      ftp.chdir("previews")
      files = ftp.nlst
      check_for_video(files, video)
    end
    ftp.close
  end

  def check_for_video(files, video)
    #
    #for file in files
    #  puts "FILE: #{file} = #{video.id.to_s}.flv"
    #end

    #s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
    #                                 APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
    #bucket = s3_connection.bucket(APP_CONFIG[CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET])
    #key_path = "#{video.s3_root_dir}/#{video.s3_key}"
    #puts "Checking for file at #{key_path}"
    #key = bucket.key(key_path, true)
    #if key.exists?
    if files.include?("#{video.id.to_s}.flv")
      print "   File exists..."
      video.finish_conversion Zencoder::Job.details(video.flixcloud_job_id, :api_key => FLIX_API_KEY).body['job']
      puts "and updated to ready state"
    else
      puts "   File not converted...skipping"
    end
  end
end