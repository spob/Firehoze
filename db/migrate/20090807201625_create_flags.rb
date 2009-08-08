require "migration_helpers"

class CreateFlags < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :flags do |t|
      t.integer :flaggable_id, :null => false
      t.string :flaggable_type, :null => false
      t.references :user, :null => false
      t.string :reason_type, :null => false, :limit => 20
      t.string :status, :null => false, :limit => 20
      t.string :comments, :null => false
      t.string :response, :null => true
      t.timestamps
    end

    add_index :flags, [:flaggable_type, :flaggable_id]
    add_foreign_key(:flags, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:flags, :user_id)
    drop_table :flags
  end
end
