class AddIndexToGiftCertificate < ActiveRecord::Migration
  def self.up
    add_index(:gift_certificates, :code, :unique => true)
  end

  def self.down
    remove_index(:gift_certificates, :code)
  end
end
