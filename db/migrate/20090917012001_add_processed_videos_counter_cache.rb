class AddProcessedVideosCounterCache < ActiveRecord::Migration
  def self.up
    add_column :lessons, :processed_videos_count, :integer, :default => 0   #
    Lesson.reset_column_information
    Lesson.all.each do |p|
      p.update_attribute :processed_videos_count, p.processed_videos.length
    end
  end

  def self.down
    remove_column :lessons, :processed_videos_count
  end
end
