# This is a periodic job that only runs one time.
#
# It inherits from the PeriodicJob base class
class RunOncePeriodicJob < PeriodicJob
  before_create :set_next_run

  # It should run right away
  def set_next_run
    self.next_run_at = Time.zone.now
  end

  # Return nil for the next_run_at field, indicating that it should not run again
  def calc_next_run
    self.next_run_at = nil
  end
end
