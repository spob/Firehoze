class AddFbColumns < ActiveRecord::Migration
  def self.up
    add_column :users, :has_fb_permissions, :boolean, :null => true
    add_column :users, :publish_to_fb, :boolean, :null => true, :default => true
  end

  def self.down
    remove_column :users, :has_fb_permissions
    remove_column :users, :publish_to_fb
  end
end
