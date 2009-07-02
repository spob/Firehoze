require "migration_helpers"

class CreateFreeCredits < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :free_credits do |t|
      t.references   :lesson,       :null => false
      t.references   :user,       :null => true
      t.datetime     :redeemed_at, :null => true
      t.timestamps
    end
    add_column :lessons, :free_credits_count, :integer, :default => 0

    add_foreign_key(:free_credits, :user_id, :users)
    add_foreign_key(:free_credits, :lesson_id, :lessons)
  end

  def self.down
    remove_foreign_key(:free_credits, :user_id)
    remove_foreign_key(:free_credits, :lesson_id)
    
    remove_column :lessons, :free_credits_count
    drop_table :free_credits
  end
end
