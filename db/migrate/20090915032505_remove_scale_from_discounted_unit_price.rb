class RemoveScaleFromDiscountedUnitPrice < ActiveRecord::Migration
  def self.up
    change_column :line_items, :discounted_unit_price, :float, :null => false
  end

  def self.down
    change_column :line_items, :discounted_unit_price, :float, :null => false, :precision => 8, :scale => 2
  end
end
