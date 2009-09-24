class AddPeriodicJobIndex < ActiveRecord::Migration
  def self.up
    add_index :periodic_jobs, [:last_run_at]
  end

  def self.down
    remove_index :periodic_jobs, [:last_run_at]
  end
end
