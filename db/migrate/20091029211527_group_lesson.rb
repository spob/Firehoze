require "migration_helpers"

class GroupLesson < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :group_lessons do |t|
      t.references :lesson, :null => false
      t.references :group,  :null => false
      t.references :user,   :null => false
      t.text       :notes
      t.timestamps
    end
    add_column :lessons, :group_lessons_count, :integer, :default => 0

    add_foreign_key(:group_lessons, :lesson_id, :lessons)
    add_foreign_key(:group_lessons, :user_id, :users)
    add_foreign_key(:group_lessons, :group_id, :groups)
  end

  def self.down
    remove_foreign_key(:group_lessons, :group_id)
    remove_foreign_key(:group_lessons, :user_id)
    remove_foreign_key(:group_lessons, :lesson_id)

    remove_column :lessons, :group_lessons_count
    
    drop_table :group_lessons
  end
end