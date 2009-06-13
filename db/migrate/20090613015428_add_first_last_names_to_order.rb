class AddFirstLastNamesToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :first_name, :string, :null => false, :limit => 50
    add_column :orders, :last_name, :string, :null => false, :limit => 50
    add_column :orders, :billing_name, :string, :null => false, :limit => 100
    add_column :orders, :address1, :string, :null => false, :limit => 150
    add_column :orders, :address2, :string, :null => true, :limit => 150
    add_column :orders, :city, :string, :null => false, :limit => 50
    add_column :orders, :state, :string, :null => false, :limit => 50
    add_column :orders, :country, :string, :null => false, :limit => 50
    add_column :orders, :zip, :string, :null => false, :limit => 25
  end

  def self.down
    remove_column :orders, :first_name
    remove_column :orders, :last_name
    remove_column :orders, :billing_name
    remove_column :orders, :address1
    remove_column :orders, :address2
    remove_column :orders, :city
    remove_column :orders, :state
    remove_column :orders, :country
    remove_column :orders, :zip
  end
end
