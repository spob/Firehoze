class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions do |t|
      t.string :code, :null => false, :limit => 15
      t.string :promotion_type, :null => false, :limit => 50
      t.date :expires_at, :null => false
      t.text :description, :null => true
      t.float :price, :null => false

      t.timestamps
    end  
    add_index :promotions, :code, :unique => true
  end

  def self.down
    drop_table :promotions
  end
end
