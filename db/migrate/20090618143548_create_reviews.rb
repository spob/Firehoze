require "migration_helpers"

class CreateReviews < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :reviews do |t|
      t.text :body,       :null => false
      t.string :title,    :null => false, :limit => 100
      t.references :user, :null => false
      t.references :lesson, :null => false
      t.timestamps
    end

    add_column :lessons, :reviews_count, :integer, :default => 0, :null => false

    add_foreign_key(:reviews, :user_id, :users)
    add_foreign_key(:reviews, :lesson_id, :lessons)
    add_index :reviews, [:lesson_id, :user_id], :unique => true
  end

  def self.down
    remove_column :lessons, :reviews_count
    
    remove_foreign_key(:reviews, :user_id)
    remove_foreign_key(:reviews, :lesson_id)

    drop_table :reviews
  end
end
