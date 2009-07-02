require "migration_helpers"

class AddMissingFkToOrder < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_foreign_key(:orders, :cart_id, :carts)
  end

  def self.down
    remove_foreign_key(:orders, :cart_id)
  end
end
