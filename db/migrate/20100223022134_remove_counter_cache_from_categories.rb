class RemoveCounterCacheFromCategories < ActiveRecord::Migration
  def self.up
    remove_column :categories, :lessons_count
  end

  def self.down
    add_column :categories, :lessons_count, :integer, :default => 0
  end
end
