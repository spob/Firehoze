class AddLevelToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :compiled_sort, :integer
  end

  def self.down
    remove_column :categories, :compiled_sort
  end
end
