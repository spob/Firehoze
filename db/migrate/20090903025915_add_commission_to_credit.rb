class AddCommissionToCredit < ActiveRecord::Migration
  def self.up
    add_column :credits, :commission_paid, :float, :null => true
  end

  def self.down
    remove_column :credits, :commission_paid
  end
end
