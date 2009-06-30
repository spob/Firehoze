class AddRatingAverageToLesson < ActiveRecord::Migration
  def self.up
    add_column :lessons, :rating_average, :decimal, :default => 0
  end

  def self.down
    remove_column :lessons, :rating_average
  end
end
