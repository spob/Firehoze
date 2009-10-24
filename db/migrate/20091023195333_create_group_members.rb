require "migration_helpers"

class CreateGroupMembers < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :group_members do |t|
      t.string :member_type
      t.references :group
      t.references :user
      t.timestamps
    end
    add_foreign_key(:group_members, :group_id, :groups)
  end

  def self.down
    remove_foreign_key(:group_members, :group_id)
    drop_table :group_members
  end
end
