class AddCounterCacheForAttachments < ActiveRecord::Migration
  def self.up
    add_column :lessons, :lesson_attachments_count, :integer, :default => 0
  end

  def self.down
    remove_column :lessons, :lesson_attachments_count
  end
end