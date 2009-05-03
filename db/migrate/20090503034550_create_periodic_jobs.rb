class CreatePeriodicJobs < ActiveRecord::Migration
  def self.up
    create_table :periodic_jobs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string   :type,           :null => false, :limit => 50
      t.text     :job,            :null => false
      t.integer  :interval
      t.datetime :last_run_at
      t.datetime :next_run_at
      t.integer  :run_at_minutes
      t.string   :last_run_result, :limit => 500
    end
  end

  def self.down
    drop_table :periodic_jobs
  end
end
