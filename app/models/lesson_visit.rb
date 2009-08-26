class LessonVisit < ActiveRecord::Base
  belongs_to :user
  belongs_to :lesson
  validates_presence_of :lesson, :session_id

  named_scope :by_lesson,
              lambda{|lesson_id|{:conditions => { :lesson_id => lesson_id }}
              }

  # Look at visits which results in the purchase of a video but which have not yet been compiled
  named_scope :uncompiled_lesson_purchases, :conditions => {:purchased_this_visit => true, :rolled_up_at => nil }

  named_scope :unowned, :conditions => {:owned => false }

  named_scope :by_session,
              lambda{|session_id|{:conditions => { :session_id => session_id }}
              }


  def self.touch(lesson, user, session_id, purchased = false)
    if ENV['RAILS_ENV'] == 'test'
      session_id = 'dummy'
    end                
    lesson_visit = LessonVisit.by_lesson(lesson.id).by_session(session_id).first
    if lesson_visit
      lesson_visit.visited_at = Time.now
      lesson_visit.user = user if user
      lesson_visit.purchased_this_visit = purchased unless lesson_visit.purchased_this_visit
      lesson_visit.save!
    else                                            
      lesson_visit = LessonVisit.create!(:user => user,
                                         :lesson => lesson,
                                         :session_id => session_id,
                                         :visited_at => Time.now,
                                         :owned => (lesson.owned_by?(user) and !purchased),
                                         :purchased_this_visit => purchased)
    end
  end
end
