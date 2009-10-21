require "migration_helpers"

class LessonFollows < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :instructor_follows, :id => false  do |t|
      t.references :user, :null => false
      t.integer :instructor_id, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end

    add_foreign_key(:instructor_follows, :user_id, :users)
    add_foreign_key(:instructor_follows, :instructor_id, :users)

    add_index :instructor_follows, [:user_id, :instructor_id], :unique => false
  end

  def self.down
    remove_foreign_key(:instructor_follows, :user_id)
    remove_foreign_key(:instructor_follows, :instructor_id)

    drop_table :instructor_follows
  end
end