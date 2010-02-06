class AddActivityCompiledAtToReview < ActiveRecord::Migration
  def self.up
    add_column :reviews, :activity_compiled_at, :datetime

    add_index :reviews, [:activity_compiled_at]
  end

  def self.down
    remove_index :reviews, [:activity_compiled_at]

    remove_column :reviews, :activity_compiled_at
  end
end
