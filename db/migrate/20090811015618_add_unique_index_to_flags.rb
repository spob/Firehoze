class AddUniqueIndexToFlags < ActiveRecord::Migration
  def self.up
    Flag.destroy_all

    remove_index :flags, [:flaggable_type, :flaggable_id]
    add_index :flags, [:flaggable_type, :flaggable_id, :user_id], :unique => true
  end

  def self.down
    remove_index :flags, [:flaggable_type, :flaggable_id, :user_id]
    add_index :flags, [:flaggable_type, :flaggable_id]
  end
end
