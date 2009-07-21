class LessonVisit < ActiveRecord::Base
  belongs_to :user
  belongs_to :lesson
  validates_presence_of :lesson, :session_id

  named_scope :by_lesson_and_session,
              lambda{|lesson_id, session_id|{:conditions => { :lesson_id => lesson_id, :session_id => session_id }}
              }

  def self.touch(lesson, user, session_id)
    if ENV['RAILS_ENV'] == 'test'
      session_id = 'dummy'
    end
    lesson_visit = LessonVisit.by_lesson_and_session(lesson.id, session_id).first
    if lesson_visit
      lesson_visit.visited_at = Time.now
      lesson_visit.user = user if user
      lesson_visit.save!
    else
      lesson_visit = LessonVisit.create!(:user => user,
                                         :lesson => lesson,
                                         :session_id => session_id,
                                         :visited_at => Time.now)
    end
  end
end
