class InstructorNotifiedAt < ActiveRecord::Migration
  def self.up
    add_column :users, :instructor_signup_notified_at, :datetime
  end

  def self.down
    remove_column :users, :instructor_signup_notified_at
  end
end

