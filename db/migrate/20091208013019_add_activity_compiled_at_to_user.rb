class AddActivityCompiledAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :activity_compiled_at, :datetime

    add_index :users, [:activity_compiled_at]
  end

  def self.down
    remove_index :users, [:activity_compiled_at]

    remove_column :users, :activity_compiled_at
  end
end
