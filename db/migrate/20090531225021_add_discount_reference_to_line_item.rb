require "migration_helpers"

class AddDiscountReferenceToLineItem < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    change_table :line_items do |t|
      t.references :discount, :null => true
    end

    add_foreign_key(:line_items, :discount_id, :discounts)
  end

  def self.down
    remove_foreign_key(:line_items, :discount_id)

    change_table :line_items do |t|
      t.remove :discount_id
    end
  end
end
