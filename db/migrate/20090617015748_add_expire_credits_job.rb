class AddExpireCreditsJob < ActiveRecord::Migration
  def self.up
    RunIntervalPeriodicJob.create(:name => 'CreditExpiration',
            :job => 'Credit.expire_unused_credits',
            :interval => 3600 * 24) #once a day
  end

  def self.down
    RunIntervalPeriodicJob.find_in_batches(
            :conditions => { :name => ['CreditExpiration']} ) do
    |job_batch|
      job_batch.each { |job| job.destroy}
    end
  end
end
