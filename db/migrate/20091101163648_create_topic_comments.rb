require "migration_helpers"

class CreateTopicComments < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :comments, :topic_id, :integer
    add_foreign_key(:comments, :topic_id, :topics)
  end

  def self.down
    remove_foreign_key(:comments, :topic_id)

    remove_column :comments, :topic_id
  end
end
