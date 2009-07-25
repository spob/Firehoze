require "migration_helpers"

class CreateComments < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :comments do |t|      
      t.string     :type,       :limit => 35
      t.text       :body,       :null => false
      t.boolean    :public,     :null => false, :default => true
      t.references :user,       :null => false
      t.references :lesson,     :null => true
      t.timestamps
    end
    add_foreign_key(:comments, :user_id, :users)
    add_foreign_key(:comments, :lesson_id, :lessons)
  end

  def self.down
    remove_foreign_key(:comments, :user_id)
    remove_foreign_key(:comments, :lesson_id)

    drop_table :comments
  end
end
