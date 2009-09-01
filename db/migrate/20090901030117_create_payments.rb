require "migration_helpers"

class CreatePayments < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :payments do |t|
      t.references :user,       :null => false
      t.float      :amount,     :null => false
      t.timestamps
    end
    add_foreign_key(:payments, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:payments, :user_id)
    
    drop_table :payments
  end
end
