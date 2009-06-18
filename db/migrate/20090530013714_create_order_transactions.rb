require "migration_helpers"

class CreateOrderTransactions < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :order_transactions do |t|
      t.references :order, :null => false
      t.string :action
      t.integer :amount
      t.boolean :success
      t.string :authorization
      t.string :message
      t.text :params
      t.timestamps
    end
    add_foreign_key(:order_transactions, :order_id, :orders)
  end

  def self.down
    remove_foreign_key(:order_transactions, :order_id)

    drop_table :order_transactions
  end
end
