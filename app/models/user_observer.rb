class UserObserver < ActiveRecord::Observer
  def after_save(user)
    if user.activity_compiled_at.nil? and user.active
      User.transaction do
        user.compile_activity
      end
    end

    if user.instructor_activity_compiled_at.nil? and user.instructor_signup_notified_at.present?
      User.transaction do
        user.compile_instructor_activity
      end
    end
  end
end
