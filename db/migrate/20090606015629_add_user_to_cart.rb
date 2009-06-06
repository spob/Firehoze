require "migration_helpers"

class AddUserToCart < ActiveRecord::Migration
    extend MigrationHelpers

  def self.up
    Cart.destroy_all
    add_column :carts, :user_id, :integer, :null => false
  end

  def self.down
    remove_column :carts, :user_id
  end
end
