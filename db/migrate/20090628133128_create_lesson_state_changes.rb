require "migration_helpers"

class CreateLessonStateChanges < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :video_status_changes do |t|
      t.references :lesson, :null => false
      t.string :from_status
      t.string :to_state, :null => false
      t.string :message
      t.timestamps
    end
    add_foreign_key(:video_status_changes, :lesson_id, :lessons)
  end

  def self.down
    remove_foreign_key(:video_status_changes, :lesson_id)
    
    drop_table :video_status_changes
  end
end
