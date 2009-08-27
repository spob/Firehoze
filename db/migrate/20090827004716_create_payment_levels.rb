class CreatePaymentLevels < ActiveRecord::Migration
  def self.up
    create_table :payment_levels do |t|
      t.string  :name, :null => false, :limit => 30
      t.float   :rate, :null => false
      t.boolean :default_payment_level, :null => false
      t.timestamps
    end
    add_index :payment_levels, [:name], :unique => true
  end

  def self.down
    remove_index :payment_levels, [:name]
    drop_table :payment_levels
  end
end
