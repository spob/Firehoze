class AddShowNameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :show_real_name, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :show_real_name
  end
end
