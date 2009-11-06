require "migration_helpers"

class AddGroupToActivity < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :activities, :group_id, :integer
    add_foreign_key(:activities, :group_id, :groups)
  end

  def self.down
    remove_foreign_key(:activities, :group_id)
    remove_column :activities, :group_id
  end
end
