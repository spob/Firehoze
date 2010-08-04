class AddFreeLessonsFlagToGroups < ActiveRecord::Migration
  def self.up               
    add_column :groups, :free_lessons_to_members, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :groups, :free_lessons_to_members
  end
end
