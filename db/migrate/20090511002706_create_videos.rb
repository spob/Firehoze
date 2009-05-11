require "migration_helpers"

class CreateVideos < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :videos do |t|
      t.string     :title,        :null => false, :limit => 150
      t.references :user,         :null => false
      t.text       :description,  :null => true
      t.timestamps
    end
    add_foreign_key(:videos, :user_id, :users)
  end

  def self.down
    drop_table :videos
  end
end
