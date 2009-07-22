require "migration_helpers"

class CreateLessonBrowse < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :lesson_visits do |t|
      t.references :lesson, :null => false
      t.references :user, :null => true
      t.timestamp  :visited_at, :null => false
      t.string     :session_id, :null => false
      t.timestamps
    end
    add_index :lesson_visits, [:session_id, :lesson_id], :unique => true
    add_foreign_key(:lesson_visits, :lesson_id, :lessons)
    add_foreign_key(:lesson_visits, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:lesson_visits, :lesson_id)
    remove_foreign_key(:lesson_visits, :user_id)
    drop_table :lesson_visits
  end
end
