class PopulateInstructionNotifiedAt < ActiveRecord::Migration
  def self.up
    User.active.instructors.each do |u|
      if u.instructor_signup_notified_at.nil
        execute("update users set instructor_signup_notified_at = '#{u.author_agreement_accepted_on.to_s(:db)}' where id = #{u.id}")
      end
    end
  end

  def self.down
    User.active.instructors.instructor_signup_notified_at_not_null.each do |u|
      execute("update users set instructor_signup_notified_at = null where id = #{u.id}")
    end
  end
end
