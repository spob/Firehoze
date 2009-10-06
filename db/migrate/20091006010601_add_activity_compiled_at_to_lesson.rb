class AddActivityCompiledAtToLesson < ActiveRecord::Migration
  def self.up
    add_column :lessons, :activity_compiled_at, :datetime

    add_index :lessons, [:activity_compiled_at]
  end

  def self.down
    remove_index :lessons, [:activity_compiled_at]

    remove_column :lessons, :activity_compiled_at
  end
end
