class LessonBuyPattern < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :purchased_lesson, :class_name => 'Lesson'
  validates_presence_of :lesson, :purchased_lesson, :counter

  def self.compile_buy_patterns
    # First find recent (uncompiled) purchases
    for visit in LessonVisit.uncompiled_lesson_purchases
      for other_visit in LessonVisit.by_session_id(visit.session_id)
        # and loop through all browsed video done on the same session
      end
    end
  end
end
