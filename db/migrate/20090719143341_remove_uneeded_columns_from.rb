class RemoveUneededColumnsFrom < ActiveRecord::Migration
  def self.up
    remove_index(:lessons, :flixcloud_job_id)

    remove_column :lessons, :video_file_name
    remove_column :lessons, :video_content_type
    remove_column :lessons, :video_file_size

    remove_column :lessons, :flixcloud_job_id
    remove_column :lessons, :conversion_started_at
    remove_column :lessons, :conversion_ended_at

    remove_column :lessons, :finished_video_file_location
    remove_column :lessons, :finished_video_width
    remove_column :lessons, :finished_video_height
    remove_column :lessons, :finished_video_file_size
    remove_column :lessons, :finished_video_cost
    remove_column :lessons, :input_video_cost

    rename_column :lessons, :state, :status
  end

  def self.down
    add_column :lessons, :video_file_name, :string, :null => true
    add_column :lessons, :video_content_type, :string
    add_column :lessons, :video_file_size, :integer
    add_column :lessons, :flixcloud_job_id, :integer
    add_column :lessons, :conversion_started_at, :datetime
    add_column :lessons, :conversion_ended_at, :datetime

    rename_column :lessons, :status, :state

    add_index(:lessons, :flixcloud_job_id, :unique => false)

    change_table :lessons do |t|
      t.column :finished_video_file_location, :string, :null => true
      t.column :finished_video_width, :integer
      t.column :finished_video_height, :integer
      t.column :finished_video_file_size, :integer
      t.column :finished_video_cost, :integer
      t.column :input_video_cost, :integer
    end
  end
end
