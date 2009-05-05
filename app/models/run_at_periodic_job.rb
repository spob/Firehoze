# == Schema Information
# Schema version: 20081021172636
#
# Table name: periodic_jobs
#
#  id              :integer(4)      not null, primary key
#  type            :string(255)
#  job             :text
#  interval        :integer(4)
#  last_run_at     :datetime
#  run_at_minutes  :integer(4)
#  last_run_result :string(500)
#  next_run_at     :datetime
#  run_counter     :integer(4)
#

class RunAtPeriodicJob < PeriodicJob
  before_create :set_next_run
  validates_presence_of :run_at_minutes
  @@now = nil

  def calc_next_run
    RunAtPeriodicJob.new(:job => self.job, :run_at_minutes => self.run_at_minutes)
  end

  def set_next_run
    self.next_run_at = calc_next_run_at_date
  end

  # Allow us to set the current timestamp for testing purposes
  def set_now(the_date)
    @@now = the_date
  end

  private

  def calc_next_run_at_date
    # has it run at the appointed time for today
    hours = self.run_at_minutes/60
    minutes = self.run_at_minutes - hours * 60

    @right_now = Time.zone.now
    @right_now = @@now unless @@now.nil?

    if @right_now.hour * 60 + @right_now.min < run_at_minutes
      self.next_run_at = Time.local(@right_now.year, @right_now.month, @right_now.day, hours, minutes, 0)
    else
      self.next_run_at = Time.local(@right_now.year, @right_now.month, @right_now.day, hours, minutes, 0) + 1.day
    end
  end
end
