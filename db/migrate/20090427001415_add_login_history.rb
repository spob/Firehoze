require "migration_helpers"

class AddLoginHistory < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :user_logons do |t|
      t.references :user,         :null => false
      t.string     :login_ip,     :limit => 20
      t.column     :lock_version, :integer, :default => 0
      t.timestamps
    end

    add_foreign_key(:user_logons, :user_id, :users)

    add_index :user_logons, :created_at, :unique => false
  end

  def self.down
    remove_foreign_key(:user_logons, :user_id)

    drop_table :user_logons
  end
end
