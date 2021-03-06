require "migration_helpers"

class Credits < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :credits do |t|
      t.references   :user,        :null => false
      t.datetime     :acquired_at, :null => false
      t.float        :price,       :null => false
      t.references   :sku,         :null => true
      t.references   :lesson,       :null => true
      t.datetime     :redeemed_at, :null => true
      t.timestamps
    end

    add_foreign_key(:credits, :user_id, :users)
    add_foreign_key(:credits, :sku_id, :skus)
    add_foreign_key(:credits, :lesson_id, :lessons)
  end

  def self.down
    remove_foreign_key(:credits, :user_id)
    remove_foreign_key(:credits, :sku_id)
    remove_foreign_key(:credits, :lesson_id)
    
    drop_table :credits
  end
end
