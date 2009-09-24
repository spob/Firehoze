class AddIndexToFreeCredits < ActiveRecord::Migration
  def self.up
    add_index :free_credits, [:redeemed_at]
  end

  def self.down
    remove_index :free_credits, [:redeemed_at]
  end
end
