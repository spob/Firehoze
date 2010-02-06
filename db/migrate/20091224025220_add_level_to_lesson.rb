class AddLevelToLesson < ActiveRecord::Migration
  def self.up
    add_column :lessons, :audience, :string, :limit => 25, :default => 'college', :null => false
  end

  def self.down
    remove_column :lessons, :audience
  end
end
