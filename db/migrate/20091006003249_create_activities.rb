require "migration_helpers"

class CreateActivities < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :activities do |t|
      t.integer  :trackable_id, :null => false
      t.string   :trackable_type, :null => false
      t.integer  :actor_user_id, :null => false
      t.integer  :actee_user_id
      t.datetime :acted_upon_at, :null => false
      t.timestamps
    end

    add_index :activities, [:trackable_type, :trackable_id]
    add_foreign_key(:activities, :actor_user_id, :users)
    add_foreign_key(:activities, :actee_user_id, :users)
  end

  def self.down
    remove_foreign_key(:activities, :actor_user_id)
    remove_foreign_key(:activities, :actee_user_id)
    drop_table :activities
  end
end
