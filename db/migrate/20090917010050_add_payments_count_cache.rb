class AddPaymentsCountCache < ActiveRecord::Migration
  def self.up
    add_column :users, :payments_count, :integer, :default => 0   #
    User.reset_column_information
    User.all.each do |p|
      p.update_attribute :payments_count, p.payments.length
    end
  end

  def self.down
    remove_column :users, :payments_count
  end
end
