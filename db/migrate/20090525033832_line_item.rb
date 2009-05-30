require "migration_helpers"

class LineItem < ActiveRecord::Migration
    extend MigrationHelpers
  
  def self.up
    create_table :line_items do |t|
      t.decimal :unit_price, :null => false, :precision => 8, :scale => 2
      t.references :sku    , :null => false
      t.references :cart   , :null => false
      t.integer :quantity  , :null => false
      t.timestamps
    end
    add_foreign_key(:line_items, :sku_id, :skus)
    add_foreign_key(:line_items, :cart_id, :carts)
  end

  def self.down
    remove_foreign_key(:line_items, :sku_id)
    remove_foreign_key(:line_items, :cart_id)
      
    drop_table :line_items
  end
end
