require "migration_helpers"

class AddStatusToComments < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    add_column :comments, :status, :string, :limit => 15
    add_column :comments, :moderator_user_id, :integer, :null => true

    Comment.reset_column_information

    Comment.update_all(:status => COMMENT_STATUS_ACTIVE)

    add_foreign_key(:comments, :moderator_user_id, :users)
  end

  def self.down
    remove_foreign_key(:comments, :moderator_user_id)
    remove_column :comments, :status
    remove_column :comments, :moderator_user_id
  end
end
