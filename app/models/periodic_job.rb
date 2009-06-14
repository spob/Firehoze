# A periodic job represents a background job that will be executed by the task_scheduler.
# this class is the base class, and multiple subclasses (e.g., RunOncePeriodicJobs) inherit
# from it.
#
# A periodic job with a last_run_at is one that has already executed, in which case it's next_run_at
# field should be nil. For jobs waiting to run, the reverse is true.
#
# For jobs which are pending, the last_run_result will be nil.
# For jobs which are currently running, the last_run_result will be 'Running'
# For jobs which have completed their execution, the last_run_result will hold 'OK', or the exception
# message if one occurred
class PeriodicJob < ActiveRecord::Base
  # The subclass will set the next_run_at value depending on the logic appropriate for
  # that type of job
  before_create :set_initial_next_run

  validates_presence_of :name, :job

  # The task scheduler will periodically check for jobs which are stuck. This could happen, for example,
  # if the task scheduler crashed during execution of the job. This is looking for jobs that are in the
  # process of running and have been doing so for a long time...a long time being a parameter that
  # can be configured in the parameters file.
  named_scope :zombies,
              :conditions => ["last_run_at < :last_run_at and next_run_at is null and last_run_result = 'Running'",
                              { :last_run_at => Time.zone.now - APP_CONFIG['periodic_job_timeout'].to_i.minutes }]

  # The task scheduler will look for jobs ready to run...specifically, those jobs for which the next_run_at
  # has already passed but have a nil last_run_result, implying that it's not yet started
  named_scope :ready_to_run,
              lambda{|now|{
                      :conditions => ['next_run_at < ? and last_run_result is null',
                                      now],
                      :order => "next_run_at ASC",
                      # only grab one in case another task # only grab one in case another task
                      # server is running -- to load balance
                      :limit => 1,
                      :lock => true}}

  # Basically paginated listing finder
  def self.list(page, per_page)
    paginate :page => page,
             :order => 'next_run_at DESC, last_run_at DESC',
             :per_page => per_page
  end

  # Check for jobs that are hung...and fail the job (which will rerun the job if appropriate
  def self.process_zombies
    #    puts "checking for zombies"
    PeriodicJob.transaction do
      for job in PeriodicJob.zombies
        #        puts "Found...#{job.id}"
        TaskServerLogger.instance.debug("Failed job #{job.id}")
        job.fail_job
      end
    end
  end

  # Retreive a list of jobs which are ready to run
  def self.find_jobs_to_run
    # first grab all rows that are ready to run...we do this (with a lock)
    # to ensure that other threads or task_schedulers won't try to run 
    # the same jobs
    jobs = []
    PeriodicJob.transaction do
      jobs = PeriodicJob.ready_to_run(Time.zone.now)
      for job in jobs
        # Update last_run_result to 'Running' to signal it is in process
        job.update_attributes(:last_run_result => 'Running')
      end
    end
    # okay, transaction should be committed (and lock freed at this point)
    # ...this instance has grabbed the jobs it wants so no one else can
    jobs
  end

  # Execute jobs pending to run. Return true iff jobs were found to run so that
  # the outer process knows to either loop back again right away to see if there are
  # more jobs, or go to sleep for the sleep period
  def self.run_jobs
    process_zombies
    TaskServerLogger.instance.debug("Checking for periodic jobs to run...")
    jobs = PeriodicJob.find_jobs_to_run
    jobs.each do |job|
      job.run!
    end
    jobs.present?
  end

  # Default dehavior for calculating the next_run date, which will be generally overriden by the
  # subclass (except for the case of a run once job).
  # When a job completes, the task scheduler will invoke this method to persist a new instance of
  # the job to run based on the value returned by this method. A return value of nil indicates
  # that the job should not run again, in which case a new job instance will not be created.
  def calc_next_run
    nil
  end

  def can_delete?
    false
  end

  # When a new record is created, calculate the time when it should first run
  def set_initial_next_run
    self.next_run_at = Time.zone.now if self.next_run_at.nil?
  end

  # Runs a job and updates the +last_run_at+ field.
  def run!
    TaskServerLogger.instance.info "Executing job id #{self.id}, #{self.to_s}..."
    begin
      self.last_run_at = Time.zone.now
      self.next_run_at = nil
      self.save
      eval(self.job)
      self.last_run_result = "OK"
      TaskServerLogger.instance.info "Job completed successfully"
    rescue Exception
      err_string = "'#{self.job}' could not run: #{$!.message}\n#{$!.backtrace}"
      TaskServerLogger.instance.error err_string
      puts err_string unless ENV['RAILS_ENV'] == "test"
      self.last_run_result = err_string.slice(1..500)
    end
    self.save

    # ...and persist the next run of this job if one exists
    set_next_job
  end

  # Mark the current job as Timed out, and rerun it...used to process zombie jobs
  def fail_job
    self.last_run_at = Time.zone.now
    self.next_run_at = nil
    self.last_run_result = "Timeout"
    self.save

    # ...and persist the next run of this job if one exists
    set_next_job
  end

  # Cleans up all jobs older than a week.
  def self.cleanup
    self.destroy_all ['last_run_at < ?', APP_CONFIG('keep_periodic_job_days').to_i.day.ago]
  end

  def to_s
    "#{self.class.to_s}: #{job}"
  end

  private

  def  set_next_job
    next_job = self.calc_next_run
    next_job.save unless next_job.nil?
  end
end