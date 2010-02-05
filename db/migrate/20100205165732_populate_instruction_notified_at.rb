class PopulateInstructionNotifiedAt < ActiveRecord::Migration
  def self.up
    User.active.instructors.instructor_signup_notified_at_null.each do |u|
      u.update_attribute(:instructor_signup_notified_at, u.author_agreement_accepted_on)
    end
  end

  def self.down
    User.active.instructors.instructor_signup_notified_at_not_null.each do |u|
      u.update_attribute(:instructor_signup_notified_at, nil)
    end
  end
end
