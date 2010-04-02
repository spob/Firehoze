class AddFbIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_id, 'bigint', :limit => 20, :null=>true
    add_column :users, :facebook_key, :string, :limit => 20
    add_column :users, :session_key, :string
    add_index :users, :facebook_id, :unique => false
    add_index :users, :facebook_key, :unique => false
  end

  def self.down
    remove_index :users, :facebook_id
    remove_index :users, :facebook_key
    remove_column :users, :facebook_key
    remove_column :users, :facebook_id
    remove_column :users, :session_key
  end
end
