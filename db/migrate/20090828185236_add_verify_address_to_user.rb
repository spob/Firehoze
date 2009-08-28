class AddVerifyAddressToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :verified_address_on, :datetime, :null => true
    remove_column :users, :country
    add_column :users, :country, :string, :null => true, :default => 'US'
  end

  def self.down
    remove_column :users, :verfified_address_on
    remove_column :users, :country
    add_column :users, :country, :string, :null => true
  end
end
