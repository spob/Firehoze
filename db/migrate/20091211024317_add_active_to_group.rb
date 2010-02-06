class AddActiveToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :active, :boolean, :default => true
  end

  def self.down
    remove_column :groups, :active
  end
end
