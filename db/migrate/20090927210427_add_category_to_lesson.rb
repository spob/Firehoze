require "migration_helpers"

class AddCategoryToLesson < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    Category.reset_column_information
    @category = Category.create!(:name => 'Uncategorized', :sort_value => 10)
    add_column :lessons, :category_id, :integer, :null => true


    execute "update lessons set category_id = #{@category.id}"

    change_column :lessons, :category_id, :integer, :null => false

    add_foreign_key(:lessons, :category_id, :categories)
  end

  def self.down
    remove_foreign_key(:lessons, :category_id) 
    Category.find_by_name("dummy").delete

    change_table :lessons do |t|
      t.remove :category_id
    end
  end
end
