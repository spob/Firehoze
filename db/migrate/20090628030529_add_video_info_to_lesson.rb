class AddVideoInfoToLesson < ActiveRecord::Migration
  def self.up
    change_table :lessons do |t|
      t.column :finished_video_file_location, :string, :null => true
      t.column :finished_video_width, :integer
      t.column :finished_video_height, :integer
      t.column :finished_video_file_size, :integer
      t.column :finished_video_duration, :integer
      t.column :finished_video_cost, :integer
      t.column :input_video_cost, :integer
      t.column :finished_video_transcoding_error, :string
    end
  end

  def self.down
    remove_column :lessons, :finished_video_file_location
    remove_column :lessons, :finished_video_width
    remove_column :lessons, :finished_video_height
    remove_column :lessons, :finished_video_file_size
    remove_column :lessons, :finished_video_duration
    remove_column :lessons, :finished_video_cost
    remove_column :lessons, :input_video_cost
    remove_column :lessons, :finished_video_transcoding_error
  end
end
