# script/task_server.rb
#!/usr/bin/env ruby
#
# Background Task Server
#
# Relies on ActiveRecord PeriodicJob and STI table (periodic_jobs):
#
# type:         string    ("RunOncePeriodicJob", "RunAtPeriodicJob",or "RunIntervalPeriodicJob")
# interval:     integer   (in seconds)
# job:          text      (actual ruby code to eval)
# last_run_at:  datetime  (stored time of last run)
#
# Main algorithm is daemon process runs every XX seconds, wakes up and
# looks for a job to run based upon the next_run_at date.
#
# Jobs for which the next_run_at time has passed are executed and stored until
# they are cleaned up.
#

options = {}
ARGV.options do |opts|

  opts.on( "-e", "--environment ENVIRONMENT", String,
           "The Rails Environment to run under." ) do |environment|
    options[:environment] = environment
  end

  opts.parse!
end

RAILS_ENV = options[:environment] || 'development'

require File.dirname(__FILE__) + '/../config/environment.rb'

# Load environment-specific values
path = "#{File.dirname(__FILE__)}/../config/environments/#{RAILS_ENV}.yml"
if File.exists?(path) && (env_config = YAML.load_file(path))
  puts "loading: #{path}"
  APP_CONFIG.merge!(env_config)
end
# parse in the Amazon s3 parameters
s3_path =  "#{File.dirname(__FILE__)}/../config/s3.yml"
APP_CONFIG.merge!(YAML.load_file(s3_path))

if RAILS_ENV == "development" or RAILS_ENV == "test"
  SLEEP_TIME = 10
else
  SLEEP_TIME = 30
end

TaskServerLogger.instance.info("Started in #{RAILS_ENV}")

loop do
  # Find all jobs waiting to run and run them
  jobs_not_found = PeriodicJob.run_jobs
  # only sleep if no jobs were found to run
  sleep(SLEEP_TIME) if !jobs_not_found
end