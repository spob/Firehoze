require "migration_helpers"

class CreateTopics < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :topics do |t|
      t.references :user, :null => false
      t.string :title, :null => false, :limit => 200
      t.references :group, :null => false
      t.boolean :pinned, :null => false, :default => false
      t.datetime :last_commented_at, :null => false
      t.integer :topic_comments_count, :default => 0
      t.timestamps
    end
    add_foreign_key(:topics, :group_id, :groups)
    add_foreign_key(:topics, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:topics, :user_id)
    remove_foreign_key(:topics, :group_id)

    drop_table :topics
  end
end
