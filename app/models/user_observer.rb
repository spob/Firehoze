class UserObserver < ActiveRecord::Observer
  def before_save(user)
    if user.email_changed? and !user.new_record?
      RunOncePeriodicJob.create!(
              :name => 'Notify Email Changed',
              :job => "User.notify_email_changed(#{user.id})")
    end
  end

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
