class AddPurchasedToLessonVisit < ActiveRecord::Migration
  def self.up
    add_column :lesson_visits, :owned, :boolean, :null => false, :default => false
    add_column :lesson_visits, :purchased_this_visit, :boolean, :null => false, :default => false
    add_column :lesson_visits, :rolled_up_at, :datetime

    add_index :lesson_visits, :rolled_up_at
  end

  def self.down
    remove_index :lesson_visits, :rolled_up_at
    
    remove_column :lesson_visits, :owned
    remove_column :lesson_visits, :purchased_this_visit
    remove_column :lesson_visits, :rolled_up_at
  end
end
