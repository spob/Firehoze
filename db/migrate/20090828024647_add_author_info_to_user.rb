require "migration_helpers"

class AddAuthorInfoToUser < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :users, :instructor_status, :string, :null => false, :limit => 25, :default => 'NO'
    add_column :users, :address1, :string, :null => true
    add_column :users, :address2, :string, :null => true
    add_column :users, :city, :string, :null => true
    add_column :users, :state, :string, :null => true
    add_column :users, :postal_code, :string, :null => true
    add_column :users, :country, :string, :null => true, :default => 'US'
    add_column :users, :author_agreement_accepted_on, :datetime, :null => true
    add_column :users, :withold_taxes, :boolean, :null => false, :default => true
    add_column :users, :payment_level_id, :integer, :null => true

    add_foreign_key(:users, :payment_level_id, :payment_levels)
  end

  def self.down
    remove_foreign_key(:users, :payment_level_id)

    remove_column :users, :instructor_status
    remove_column :users, :address1
    remove_column :users, :address2
    remove_column :users, :city
    remove_column :users, :state
    remove_column :users, :postal_code
    remove_column :users, :country
    remove_column :users, :author_agreement_accepted_on
    remove_column :users, :withold_taxes
    remove_column :users, :payment_level_id
  end
end
