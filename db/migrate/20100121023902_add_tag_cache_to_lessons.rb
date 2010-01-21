class AddTagCacheToLessons < ActiveRecord::Migration
  def self.up
    add_column :lessons, :cached_tag_list, :string

    Lesson.reset_column_information

    Lesson.all.each do |l|
      l.update_attribute(:cached_tag_list, l.save_cached_tag_list)
    end
  end

  def self.down
    remove_column :lessons, :cached_tag_list
  end
end
