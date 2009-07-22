require "migration_helpers"

class CreateLessonBuyPattern < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :lesson_buy_patterns do |t|
      t.references :lesson, :null => false
      t.integer :purchased_lesson_id, :null => false
      t.integer :counter, :null => false
      t.timestamps
    end
    add_foreign_key(:lesson_buy_patterns, :lesson_id, :lessons)
    add_foreign_key(:lesson_buy_patterns, :purchased_lesson_id, :lessons)
  end

  def self.down                                                  
    remove_foreign_key(:lesson_buy_patterns, :lesson_id)
    remove_foreign_key(:lesson_buy_patterns, :purchased_lesson_id)

    drop_table :lesson_buy_patterns
  end
end
