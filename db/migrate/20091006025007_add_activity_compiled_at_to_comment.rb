class AddActivityCompiledAtToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :activity_compiled_at, :datetime

    add_index :comments, [:activity_compiled_at]
  end

  def self.down
    remove_index :comments, [:activity_compiled_at]

    remove_column :comments, :activity_compiled_at
  end
end
