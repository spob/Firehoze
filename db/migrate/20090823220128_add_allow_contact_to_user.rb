class AddAllowContactToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :allow_contact, :string, :null => false, :default => 'NONE', :limit => 25
  end

  def self.down
    remove_column :users, :allow_contact
  end
end
