class AddDeltaToLessons < ActiveRecord::Migration
  def self.up
    add_column :lessons, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :lessons, :delta
  end
end
