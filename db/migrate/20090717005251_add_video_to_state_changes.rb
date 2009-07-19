require "migration_helpers"

class AddVideoToStateChanges < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :video_status_changes, :video_id, :integer, :null => true

    add_foreign_key(:video_status_changes, :video_id, :videos)
  end

  def self.down
    remove_foreign_key(:video_status_changes, :video_id)

    change_table :video_status_changes do |t|
      t.remove :video_id
    end
  end
end
