class AddDataToPeriodicJobs < ActiveRecord::Migration
  def self.up
    add_column :periodic_jobs, :data, :text, :null => true
  end

  def self.down
    remove_column :periodic_jobs, :data
  end
end
