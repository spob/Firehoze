class AddActivityToCredits < ActiveRecord::Migration
  def self.up
    add_column :credits, :activity_compiled_at, :datetime

    add_index :credits, [:activity_compiled_at]
  end

  def self.down
    remove_index :credits, [:activity_compiled_at]

    remove_column :credits, :activity_compiled_at
  end
end
