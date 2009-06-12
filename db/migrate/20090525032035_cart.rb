require "migration_helpers"

class Cart < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :carts do |t|
      t.datetime :purchased_at
      t.references :user, :null => false
      t.timestamps
    end
    add_foreign_key(:carts, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:carts, :user_id)
    
    drop_table :carts
  end
end
