# This is a periodic job that runs every x number of seconds, where x is defined by the interval field.
# It inherits from the PeriodicJob base class
class RunIntervalPeriodicJob < PeriodicJob
  before_create :set_next_run_at_date

  # Instantiate a new instance of this type of job (called after this job has run) which all the same
  # settings as this job except with the next_run_at based upon the run_at_minutes
  def calc_next_run
    # puts "Calc next run #{Time.zone.now}, #{self.interval} #{(Time.zone.now + self.interval)}"
    return RunIntervalPeriodicJob.new(:name => self.name, :job => self.job,
                                      :interval => self.interval)
  end

  # Calculate the next time this job should run based upon the interval parameter
  def set_next_run_at_date
    self.next_run_at = Time.zone.now + self.interval
  end
end
