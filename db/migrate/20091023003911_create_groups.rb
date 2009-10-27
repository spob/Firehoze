require "migration_helpers"

class CreateGroups < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :groups do |t|
      t.string  :name,       :null => false
      t.boolean :private,    :null => false
      t.integer :owner_id,   :null => false
      t.references :category, :null => false
      t.boolean :delta,      :default => true, :null => false
      t.text    :description
      t.integer :group_members_count, :default => 0
      t.timestamps
    end

    add_foreign_key(:groups, :owner_id, :users)
    add_foreign_key(:groups, :category_id, :categories)
    add_index(:groups, :name, :unique => true)
  end

  def self.down
    remove_index(:groups, :name)
    remove_foreign_key(:groups, :category_id)
    remove_foreign_key(:groups, :owner_id)
    drop_table :groups
  end
end