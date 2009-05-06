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

class RunIntervalPeriodicJob < PeriodicJob
  before_create :set_next_run_at_date

  def calc_next_run
    # puts "Calc next run #{Time.zone.now}, #{self.interval} #{(Time.zone.now + self.interval)}"
    return RunIntervalPeriodicJob.new(:name => self.name, :job => self.job,
            :interval => self.interval)
  end

  def set_next_run_at_date
      self.next_run_at = Time.zone.now + self.interval
  end
end
