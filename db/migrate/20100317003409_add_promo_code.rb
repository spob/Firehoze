require "migration_helpers"

class AddPromoCode < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    add_column :users, :promotion_id, :integer
    add_foreign_key(:users, :promotion_id, :promotions)
  end

  def self.down
    remove_foreign_key(:users, :promotion_id)
    remove_column :users, :promotion_id
  end
end
