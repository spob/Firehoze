class AddGroupsOnlyToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :visible_to_lessons, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :categories, :visible_to_lessons
  end
end
