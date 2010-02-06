class AddCounterCacheToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :lessons_count, :integer, :default => 0
    Category.reset_column_information
    Category.all.each do |p|
      p.update_attribute :lessons_count, p.lessons.length
    end
  end

  def self.down
    remove_column :categories, :lessons_count
  end
end