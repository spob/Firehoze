class AddAuthorizableIndex < ActiveRecord::Migration
  def self.up
    add_index :roles, [:authorizable_id]
  end

  def self.down
    remove_index :roles, [:authorizable_id]
  end
end
