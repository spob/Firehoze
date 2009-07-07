class AddDescriptionToGiftCerts < ActiveRecord::Migration
  def self.up
    change_table :gift_certificates do |t|
      t.column :comments, :string
    end
  end

  def self.down
    remove_column :gift_certificates, :comments
  end
end
