require "migration_helpers"

class CreateCategories < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :categories do |t|
      t.string     :name,          :null => false, :limit => 50 
      t.integer    :parent_category_id, :null => true
      t.integer    :sort_value, :null => true
      t.timestamps
    end
    add_foreign_key(:categories, :parent_category_id, :categories)
    add_index(:categories, :name, :unique => true)
  end

  def self.down
    remove_index(:categories, :name)
    remove_foreign_key(:categories, :parent_category_id)
    
    drop_table :categories
  end
end
