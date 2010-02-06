class AddNotificationSentToLessons < ActiveRecord::Migration
  def self.up
    add_column :lessons, :ready_notified_at, :datetime

    Lesson.reset_column_information

    # Update records that match our conditions but limit it to 5 ordered by date
    Lesson.update_all( "ready_notified_at = now()", ["status = ?", LESSON_STATUS_READY] )
  end

  def self.down
    remove_column :lessons, :ready_notified_at
  end
end
