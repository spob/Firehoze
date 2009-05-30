require "migration_helpers"

class CreateOrders < ActiveRecord::Migration
    extend MigrationHelpers

  def self.up
    create_table :orders do |t|
      t.integer :cart_id,      :null => false
      t.string :ip_address,    :null => false
      t.references :user,      :null => false
      t.string :card_type,     :null => false
      t.date :card_expires_on, :null => false
      t.timestamps
    end

    add_foreign_key(:orders, :user_id, :users)
  end
  
  def self.down
    remove_foreign_key(:orders, :user_id)
    
    drop_table :orders
  end
end
