class AddCodeToPaymentLevel < ActiveRecord::Migration
  def self.up
    execute("delete from payment_levels")
    add_column :payment_levels, :code, :string, :null => false, :limit => 5
    add_index :payment_levels, :code, :unique => true
  end

  def self.down
    remove_foreign_key(:payment_levels, :code)
    remove_column :payment_levels, :code
  end
end
