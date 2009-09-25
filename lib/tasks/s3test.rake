require 'net/ftp'

namespace :cdn do
  desc "test stuff"
  task :test => :environment do
    for x in 1..999999 do
      s3_connection = RightAws::S3.new(APP_CONFIG[CONFIG_AWS_ACCESS_KEY_ID],
                                       APP_CONFIG[CONFIG_AWS_SECRET_ACCESS_KEY])
      bucket = s3_connection.bucket("assets.firehoze.com")
      key_path = "simplecdn_test.txt"
      key = bucket.key(key_path, true)
      puts "Wrote to file at #{Time.zone.now} (iteration #{x})"
      key.put("Touched at #{Time.zone.now}", 'public-read')
      sleep 60 * 10
    end
  end
end