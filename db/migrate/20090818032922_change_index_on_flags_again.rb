class ChangeIndexOnFlagsAgain < ActiveRecord::Migration
  def self.up
    # make index so it is no longer unique
    remove_index :flags, [:flaggable_type, :flaggable_id, :user_id]
    add_index :flags, [:flaggable_type, :flaggable_id, :user_id]
  end

  def self.down
    remove_index :flags, [:flaggable_type, :flaggable_id, :user_id]
    add_index :flags, [:flaggable_type, :flaggable_id, :user_id], :unique => true
  end
end
