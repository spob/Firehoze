class AddUniqueOnNameOfRole < ActiveRecord::Migration
  def self.up
    add_index :roles, [:name], :unique => true
  end

  def self.down
    remove_index :roles, [:name]
  end
end
