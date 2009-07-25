require "migration_helpers"

class CreateWishes < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :wishes, :id => false, :force => true  do |t|
      t.references :user,       :null => false
      t.references :lesson,     :null => false
      t.timestamps
    end

    add_foreign_key(:wishes, :lesson_id, :lessons)
    add_foreign_key(:wishes, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:wishes, :lesson_id)
    remove_foreign_key(:wishes, :user_id)

    drop_table :wishes
  end
end
