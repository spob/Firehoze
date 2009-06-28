class RemoveErrorColumnFromLesson < ActiveRecord::Migration
  def self.up
    remove_column :lessons, :finished_video_transcoding_error
  end

  def self.down
    change_table :lessons do |t|
      t.column :finished_video_transcoding_error, :string
    end
  end
end
