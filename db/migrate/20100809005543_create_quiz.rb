require "migration_helpers"

class CreateQuiz < ActiveRecord::Migration
    extend MigrationHelpers
    
  def self.up
    create_table :quizzes do |t|
      t.string     :name,          :null => false, :limit => 100
      t.integer    :group_id,      :null => false
      t.text       :description,   :null => true
      t.datetime   :disabled_at,   :null => true
      t.timestamps
    end
    add_foreign_key(:quizzes, :group_id, :groups)

    add_column :groups, :quizzes_count, :integer, :default => 0
  end

  def self.down
    remove_column :groups, :quizzes_count
    
    remove_foreign_key(:quizzes, :group_id)

    drop_table :quizzes
  end
end
