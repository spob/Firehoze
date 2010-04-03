class DropLockVersionOnUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :lock_version
  end

  def self.down
    add_column :users, :lock_version, :integer, :default=>0
  end
end
