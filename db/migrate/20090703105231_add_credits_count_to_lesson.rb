class AddCreditsCountToLesson < ActiveRecord::Migration
  def self.up
    add_column :lessons, :credits_count, :integer
  end

  def self.down
    remove_column :lessons, :credits_count
  end
end
