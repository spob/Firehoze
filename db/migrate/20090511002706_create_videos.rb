require "migration_helpers"

class CreateVideos < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :videos do |t|
      t.string     :title,        :null => false, :limit => 150
      t.integer    :author_id,    :null => false
      t.text       :description,  :null => true
      t.timestamps
    end
    add_foreign_key(:videos, :author_id, :users)
  end

  def self.down
    remove_foreign_key(:videos, :author_id)

    drop_table :videos
  end
end
