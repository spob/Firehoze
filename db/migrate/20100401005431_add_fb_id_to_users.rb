class AddFbIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_id, 'bigint', :null=>true
    add_column :users, :session_key, string
    add_index :users, :facebook_id, :unique => false
  end

  def self.down
    remove_index :users, :facebook_id
    remove_column :users, :session_key       
    remove_index :users, :facebook_id
  end
end
