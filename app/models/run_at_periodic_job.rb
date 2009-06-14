# This is a periodic job that runs at the same time once day (e.g., run at 3:00 every morning).
# The time it should run is defined by the value of the run_at_minutes field, which stores the
# number of minutes after minute when this job should run.
# It inherits from the PeriodicJob base class
class RunAtPeriodicJob < PeriodicJob
  before_create :set_next_run
  validates_presence_of :run_at_minutes
  @@now = nil

  # Instantiate a new instance of this type of job (called after this job has run) which all the same
  # settings as this job except with the next_run_at based upon the run_at_minutes
  def calc_next_run
    RunAtPeriodicJob.new(:name => self.name, :job => self.job, :run_at_minutes => self.run_at_minutes)
  end

  # Calculate the next time this job should run based upon the run_at_minutes field
  def set_next_run
    self.next_run_at = calc_next_run_at_date
  end

  # Allow us to set the current timestamp for testing purposes
  def set_now(the_date)
    @@now = the_date
  end

  private

  def calc_next_run_at_date
    # has it run at the appointed time for today?
    hours = self.run_at_minutes/60
    minutes = self.run_at_minutes - hours * 60

    @right_now = Time.zone.now
    # set the current time to the value of the @@now parameter (if set). This is used for testing
    # purposes only...@now will always be nil except for certain unit tests
    @right_now = @@now unless @@now.nil?

    if @right_now.hour * 60 + @right_now.min < run_at_minutes
      # It's not yet run today, so set the time to run to todays date
      self.next_run_at = Time.local(@right_now.year, @right_now.month, @right_now.day, hours, minutes, 0)
    else
      # otherwise the time to run has already passed, so run it at that time tomorrow
      self.next_run_at = Time.local(@right_now.year, @right_now.month, @right_now.day, hours, minutes, 0) + 1.day
    end
  end
end
