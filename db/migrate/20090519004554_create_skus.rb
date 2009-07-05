class CreateSkus < ActiveRecord::Migration
  def self.up
    create_table :skus do |t|
      t.string       :sku,          :null => false, :limit => 30
      t.string       :description,  :null => false, :limit => 150
      t.string       :type,         :null => false, :limit => 50
      t.integer      :num_credits,  :null => true
      t.float        :price,        :null => true
      t.timestamps
    end

    add_index :skus, :sku, :unique => true
  end

  def self.down
    drop_table :skus
  end
end
