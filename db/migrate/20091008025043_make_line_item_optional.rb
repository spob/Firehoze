class MakeLineItemOptional < ActiveRecord::Migration
  def self.up
    change_column :gift_certificates, :line_item_id, :integer, :null => true
  end

  def self.down
    change_column :gift_certificates, :line_item_id, :integer, :null => false
  end
end
