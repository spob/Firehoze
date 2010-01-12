class AddLockVersion < ActiveRecord::Migration
  def self.up
    add_column :activities, :lock_version, :integer, :default=>0
    add_column :ancestor_categories, :lock_version, :integer, :default=>0
    add_column :carts, :lock_version, :integer, :default=>0
    add_column :categories, :lock_version, :integer, :default=>0
    add_column :comments, :lock_version, :integer, :default=>0
    add_column :credits, :lock_version, :integer, :default=>0
    add_column :discounts, :lock_version, :integer, :default=>0
    add_column :exploded_categories, :lock_version, :integer, :default=>0
    add_column :flags, :lock_version, :integer, :default=>0
    add_column :free_credits, :lock_version, :integer, :default=>0
    add_column :gift_certificates, :lock_version, :integer, :default=>0
    add_column :group_invitations, :lock_version, :integer, :default=>0
    add_column :group_members, :lock_version, :integer, :default=>0
    add_column :groups, :lock_version, :integer, :default=>0
    add_column :helpfuls, :lock_version, :integer, :default=>0
    add_column :group_lessons, :lock_version, :integer, :default=>0
    add_column :lesson_attachments, :lock_version, :integer, :default=>0
    add_column :lesson_buy_pairs, :lock_version, :integer, :default=>0
    add_column :lesson_buy_patterns, :lock_version, :integer, :default=>0
    add_column :lesson_visits, :lock_version, :integer, :default=>0
    add_column :lessons, :lock_version, :integer, :default=>0
    add_column :line_items, :lock_version, :integer, :default=>0
    add_column :order_transactions, :lock_version, :integer, :default=>0
    add_column :orders, :lock_version, :integer, :default=>0
    add_column :payment_levels, :lock_version, :integer, :default=>0
    add_column :payments, :lock_version, :integer, :default=>0
    add_column :rates, :lock_version, :integer, :default=>0
    add_column :reviews, :lock_version, :integer, :default=>0
    add_column :skus, :lock_version, :integer, :default=>0
    add_column :topics, :lock_version, :integer, :default=>0
    add_column :tweets, :lock_version, :integer, :default=>0
    add_column :users, :lock_version, :integer, :default=>0
    add_column :video_status_changes, :lock_version, :integer, :default=>0
    add_column :videos, :lock_version, :integer, :default=>0
    add_column :wishes, :lock_version, :integer, :default=>0
  end

  
  def self.down
    remove_column :activities, :lock_version
    remove_column :ancestor_categories, :lock_version
    remove_column :carts, :lock_version
    remove_column :categories, :lock_version
    remove_column :comments, :lock_version
    remove_column :credits, :lock_version
    remove_column :discounts, :lock_version
    remove_column :exploded_categories, :lock_version
    remove_column :flags, :lock_version
    remove_column :free_credits, :lock_version
    remove_column :gift_certificates, :lock_version
    remove_column :group_invitations, :lock_version
    remove_column :group_lessons, :lock_version
    remove_column :group_members, :lock_version
    remove_column :groups, :lock_version
    remove_column :helpfuls, :lock_version
    remove_column :lesson_attachments, :lock_version
    remove_column :lesson_buy_pairs, :lock_version
    remove_column :lesson_buy_patterns, :lock_version
    remove_column :lesson_visits, :lock_version
    remove_column :lessons, :lock_version
    remove_column :line_items, :lock_version
    remove_column :order_transactions, :lock_version
    remove_column :orders, :lock_version
    remove_column :payment_levels, :lock_version
    remove_column :payments, :lock_version
    remove_column :rates, :lock_version
    remove_column :reviews, :lock_version
    remove_column :skus, :lock_version
    remove_column :topics, :lock_version
    remove_column :tweets, :lock_version
    remove_column :users, :lock_version
    remove_column :video_status_changes, :lock_version
    remove_column :videos, :lock_version
    remove_column :wishes, :lock_version
  end
end