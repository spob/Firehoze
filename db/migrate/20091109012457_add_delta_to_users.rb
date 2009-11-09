require "migration_helpers"

class AddDeltaToUsers < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :users, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    change_table :users do |t|
      t.remove :delta
    end
  end
end