class AddCounterCacheToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :users_count, :integer, :default => 0
  end

  def self.down
    remove_column :promotions, :users_count
  end
end
