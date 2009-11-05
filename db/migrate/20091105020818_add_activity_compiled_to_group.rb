class AddActivityCompiledToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :activity_compiled_at, :datetime

    add_index :groups, [:activity_compiled_at]
  end

  def self.down
    remove_index :groups, [:activity_compiled_at]

    remove_column :groups, :activity_compiled_at
  end
end
