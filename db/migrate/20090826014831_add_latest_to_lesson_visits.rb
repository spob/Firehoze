class AddLatestToLessonVisits < ActiveRecord::Migration
  def self.up
    add_column :lesson_visits, :latest, :boolean, :null => false, :default => true
    add_index :lesson_visits, [:latest]
  end

  def self.down
    remove_index :lesson_visits, [:latest]
    remove_column :lesson_visits, :latest
  end
end
