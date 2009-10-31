class AddAdminOnlyToPaymentLevel < ActiveRecord::Migration
  def self.up
    add_column :payment_levels, :admin_only, :boolean, :default => false
  end

  def self.down
    remove_column :payment_levels, :admin_only
  end
end
