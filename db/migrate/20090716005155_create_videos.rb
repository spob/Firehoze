require "migration_helpers"

class CreateVideos < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :videos do |t|
      t.references :lesson, :null => false
      t.column :type, :string, :null => false
      t.column :format, :string, :null => false
      t.column :video_file_name, :string, :null => false
      t.column :s3_key, :string
      t.column :s3_path, :string
      t.column :url, :string
      t.column :video_content_type, :string
      t.column :video_file_size, :integer
      t.column :status, :string, :null => false
      t.column :flixcloud_job_id, :integer
      t.column :video_width, :integer
      t.column :video_height, :integer
      t.column :video_file_size, :integer
      t.column :video_duration, :integer
      t.column :processed_video_cost, :integer
      t.column :input_video_cost, :integer
      t.column :video_transcoding_error, :string
      t.column :thumbnail_url, :string
      t.integer :converted_from_video_id
      t.datetime :conversion_started_at
      t.datetime :conversion_ended_at
      t.timestamps
    end
    add_index :videos, :flixcloud_job_id
    add_foreign_key(:videos, :lesson_id, :lessons)
    add_foreign_key(:videos, :converted_from_video_id, :videos)

    execute "ALTER TABLE lessons MODIFY COLUMN video_file_name VARCHAR(255) NULL"
  end

  def self.down
    remove_foreign_key(:videos, :lesson_id)
    remove_foreign_key(:videos, :converted_from_video_id)
    drop_table :videos
  end
end
