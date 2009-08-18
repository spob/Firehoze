class AddRejectedBioFlagToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :rejected_bio, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :rejected_bio
  end
end
