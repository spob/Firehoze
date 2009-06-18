class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index(:periodic_jobs, :next_run_at)
    #add_index(:skus, :sku, :unique => true)
  end

  def self.down
    remove_index(:periodic_jobs, :next_run_at)
    #remove_index(:skus, :sku)
  end
end
