require "migration_helpers"

class CreateLessonBuyAffiliates < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :lesson_buy_pairs do |t|
      t.references :lesson, :null => false
      t.integer :other_lesson_id, :null => false
      t.integer :counter, :null => false
      t.timestamps
    end
    add_foreign_key(:lesson_buy_pairs, :lesson_id, :lessons)
    add_foreign_key(:lesson_buy_pairs, :other_lesson_id, :lessons)

    add_column :credits, :rolled_up_at, :datetime
    add_index :credits, :rolled_up_at
  end

  def self.down
    remove_index :credits, :rolled_up_at
    remove_column :credits, :rolled_up_at
    
    remove_foreign_key(:lesson_buy_pairs, :lesson_id)
    remove_foreign_key(:lesson_buy_pairs, :other_lesson_id)

    drop_table :lesson_buy_pairs
  end
end
