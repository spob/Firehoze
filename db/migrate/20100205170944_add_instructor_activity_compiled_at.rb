class AddInstructorActivityCompiledAt < ActiveRecord::Migration
  def self.up
    add_column :users, :instructor_activity_compiled_at, :datetime
  end

  def self.down
    remove_column :users, :instructor_activity_compiled_at
  end
end
