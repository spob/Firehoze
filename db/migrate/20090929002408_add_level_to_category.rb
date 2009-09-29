class AddLevelToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :level, :integer
    add_column :categories, :compiled_sort, :integer
  end

  def self.down
    remove_column :categories, :level
    remove_column :categories, :compiled_sort
  end
end
