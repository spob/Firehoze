class AddReferredByToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :referred_by, :string, :limit => 40
  end

  def self.down
    remove_column :users, :referred_by
  end
end
