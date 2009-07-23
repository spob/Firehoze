class LessonBuyPattern < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :purchased_lesson, :class_name => 'Lesson'
  validates_presence_of :lesson, :purchased_lesson, :counter

  named_scope :by_lesson,
              lambda{|lesson_id|{:conditions => { :lesson_id => lesson_id }}
              }
  named_scope :by_purchased_lesson,
              lambda{|purchased_lesson_id|{:conditions => { :purchased_lesson_id => purchased_lesson_id }}
              }

  def self.rollup_buy_patterns
    # First find recent (uncompiled) purchases
    LessonBuyPattern.transaction do
      for visit in LessonVisit.uncompiled_lesson_purchases
        puts "here for #{visit.id}"
        visit.update_attribute(:rolled_up_at, Time.zone.now)
        for other_visit in LessonVisit.by_session(visit.session_id)
          buy_pattern = LessonBuyPattern.by_purchased_lesson(visit.lesson.id).by_lesson(other_visit.lesson.id).first
          if buy_pattern
            puts "Found #{buy_pattern.id} with counter #{buy_pattern.counter}"
            buy_pattern.update_attributes!(:counter => buy_pattern.counter + 1)
          else
            LessonBuyPattern.create!(:purchased_lesson => visit.lesson,
                                     :lesson => other_visit.lesson,
                                     :counter => 1)
          end
        end
      end
    end
  end
end
