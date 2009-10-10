require "migration_helpers"

class CreateAttachments < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :attachments do |t|
      t.references :lesson,       :null => false
      t.string     :attachment_file_name
      t.string     :attachment_content_type
      t.integer    :attachment_file_size
      t.datetime   :attachment_updated_at
      t.timestamps
    end
    add_foreign_key(:attachments, :lesson_id, :lessons)
  end

  def self.down
    remove_foreign_key(:attachments, :lesson_id)        

    drop_table :attachments
  end
end