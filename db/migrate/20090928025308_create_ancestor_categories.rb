require "migration_helpers"

class CreateAncestorCategories < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :ancestor_categories do |t|
      t.integer    :category_id,          :null => false
      t.integer    :ancestor_category_id, :null => false
      t.integer    :generation,           :null => false
      t.string     :ancestor_name,        :null => false
      t.string     :name,                 :null => false
      t.timestamps
    end
    add_foreign_key(:ancestor_categories, :category_id, :categories)
    add_foreign_key(:ancestor_categories, :ancestor_category_id, :categories)
  end

  def self.down
    remove_foreign_key(:ancestor_categories, :category_id)
    remove_foreign_key(:ancestor_categories, :ancestor_category_id) 

    drop_table :ancestor_categories
  end
end
