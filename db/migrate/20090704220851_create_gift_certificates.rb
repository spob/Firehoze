require "migration_helpers"

class CreateGiftCertificates < ActiveRecord::Migration
    extend MigrationHelpers

  def self.up
    create_table :gift_certificates do |t|
      t.string     :code,            :limit => 16, :null => false
      t.references :user,            :null => false
      t.references :gift_certificate_sku, :null => false
      t.integer    :credit_quantity, :null => false
      t.float      :price,           :null => false
      t.timestamps
    end

    add_foreign_key(:gift_certificates, :gift_certificate_sku_id, :skus)   
    add_foreign_key(:gift_certificates, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:gift_certificates, :gift_certificate_sku_id)
    remove_foreign_key(:gift_certificates, :user_id)
    
    drop_table :gift_certificates
  end
end
