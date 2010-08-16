require "migration_helpers"

class CreateQuestion < ActiveRecord::Migration
    extend MigrationHelpers

  def self.up
    create_table   :questions do |t|
      t.string     :question,          :null => false, :limit => 500
      t.integer    :quiz_id,      :null => false
      t.timestamps
    end
    add_foreign_key(:questions, :quiz_id, :quizzes)

    add_column :quizzes, :questions_count, :integer, :default => 0
  end

  def self.down
    remove_column :quizzes, :questions_count

    remove_foreign_key(:questions, :quiz_id)

    drop_table :questions
  end
end
