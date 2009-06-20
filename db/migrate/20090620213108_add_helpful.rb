require "migration_helpers"

class AddHelpful < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :helpfuls do |t|
      t.references :user, :null => false
      t.references :review, :null => false
      t.boolean    :helpful, :null => false
      t.timestamps
    end
    add_foreign_key(:helpfuls, :user_id, :users)
    add_foreign_key(:helpfuls, :review_id, :reviews)
    add_index :helpfuls, [:review_id, :user_id], :unique => true
  end

  def self.down
    remove_foreign_key(:helpfuls, :user_id)
    remove_foreign_key(:helpfuls, :review_id)

    drop_table :helpfuls
  end                                               
end
