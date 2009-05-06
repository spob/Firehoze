class AddPeriodicJobs < ActiveRecord::Migration
  def self.up
    RunIntervalPeriodicJob.create(:name => 'SessionCleaner',
            :job => 'SessionCleaner.clean',
            :interval => 3600 * 24) #once a day
    RunIntervalPeriodicJob.create(:name => 'PeriodicJobCleanup',
            :job => 'PeriodicJob.cleanup', :interval => 3600) #once an hour
  end

  def self.down
    RunIntervalPeriodicJob.find_in_batches(
            :conditions => { :name => ['SessionCleaner', 'PeriodicJobCleanup']} ) do
    |job_batch|
      job_batch.each { |job| job.destroy}
    end
  end
end
