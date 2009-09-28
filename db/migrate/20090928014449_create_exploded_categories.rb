require "migration_helpers"

class CreateExplodedCategories < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :exploded_categories do |t|
      t.integer    :category_id,      :null => false
      t.integer    :base_category_id, :null => false
      t.string     :base_name,        :null => false
      t.string     :name,             :null => false
      t.integer    :level,            :null => false
      t.timestamps
    end
    add_foreign_key(:exploded_categories, :category_id, :categories)
    add_foreign_key(:exploded_categories, :base_category_id, :categories)
  end

  def self.down
    remove_foreign_key(:exploded_categories, :category_id)
    remove_foreign_key(:exploded_categories, :base_category_id) 

    drop_table :exploded_categories
  end
end
