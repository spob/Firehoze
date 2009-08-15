require "migration_helpers"

class AddStatusToReview < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :reviews, :status, :string, :limit => 15
    add_column :reviews, :moderator_user_id, :integer, :null => true

    Review.reset_column_information

    Review.update_all(:status => REVIEW_STATUS_ACTIVE)

    add_foreign_key(:reviews, :moderator_user_id, :users)
  end

  def self.down
    remove_foreign_key(:reviews, :moderator_user_id)
    remove_column :reviews, :status
    remove_column :reviews, :moderator_user_id
  end
end
