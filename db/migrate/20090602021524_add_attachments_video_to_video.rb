class AddAttachmentsVideoToVideo < ActiveRecord::Migration
  def self.up
    add_column :lessons, :video_file_name, :string, :null => false
    add_column :lessons, :video_content_type, :string
    add_column :lessons, :video_file_size, :integer
  end

  def self.down
    remove_column :lessons, :video_file_name
    remove_column :lessons, :video_content_type
    remove_column :lessons, :video_file_size
  end
end
