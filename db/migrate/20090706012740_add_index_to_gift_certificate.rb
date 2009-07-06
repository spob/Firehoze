require "migration_helpers"

class AddIndexToGiftCertificate < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    add_index(:gift_certificates, :code, :unique => true)

    change_table :gift_certificates do |t|
      t.column :redeemed_at, :datetime
      t.column :redeemed_by_user_id, :integer
    end

    add_foreign_key(:gift_certificates, :redeemed_by_user_id, :users)
  end

  def self.down
    remove_foreign_key(:gift_certificates, :redeemed_by_user_id)

    remove_column :gift_certificates, :redeemed_at
    remove_column :gift_certificates, :redeemed_by_user_id

    remove_index(:gift_certificates, :code)
  end
end
