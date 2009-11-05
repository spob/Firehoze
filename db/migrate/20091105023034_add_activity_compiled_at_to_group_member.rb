class AddActivityCompiledAtToGroupMember < ActiveRecord::Migration
  def self.up
    add_column :group_members, :activity_compiled_at, :datetime

    add_index :group_members, [:activity_compiled_at]
  end

  def self.down
    remove_index :group_members, [:activity_compiled_at]

    remove_column :group_members, :activity_compiled_at
  end
end
