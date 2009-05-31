require "migration_helpers"

class CreateDiscounts < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :discounts do |t|
      t.references :sku
      t.string     :type,   :null => false, :limit => 25
      t.integer    :minimum_quantity
      t.float      :percent_discount
      t.timestamps
    end
    add_foreign_key(:discounts, :sku_id, :skus)
  end

  def self.down
    remove_foreign_key(:discounts, :sku_id)
    drop_table :discounts
  end
end
