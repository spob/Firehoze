require "migration_helpers"

class CreateLessons < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :lessons do |t|
      t.string     :title,         :null => false, :limit => 150
      t.integer    :instructor_id, :null => false
      t.text       :description,   :null => true
      t.timestamps
    end
    add_foreign_key(:lessons, :instructor_id, :users)
  end

  def self.down
    remove_foreign_key(:lessons, :instructor_id)

    drop_table :lessons
  end
end
