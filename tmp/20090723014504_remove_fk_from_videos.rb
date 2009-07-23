require "migration_helpers"

class RemoveFkFromVideos < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
      remove_foreign_key(:videos, :converted_from_video_id)
  end

  def self.down
    add_foreign_key(:videos, :converted_from_video_id, :videos)
  end
end
