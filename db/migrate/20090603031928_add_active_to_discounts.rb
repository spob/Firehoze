class AddActiveToDiscounts < ActiveRecord::Migration
  def self.up
    add_column :discounts, :active, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :discounts, :active
  end
end
