class LessonBuyPair < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :other_lesson, :class_name => 'Lesson'
  validates_presence_of :lesson, :other_lesson, :counter

  named_scope :by_lesson,
              lambda{|lesson_id|{:conditions => { :lesson_id => lesson_id }}
              }
  named_scope :by_other_lesson,
              lambda{|other_lesson_id|{:conditions => { :other_lesson_id => other_lesson_id }}
              }

  def self.rollup_buy_patterns
    # First find recent (uncompiled) purchases
    LessonBuyPair.transaction do
      for credit in Credit.used.unrolled_up
        credit.update_attribute(:rolled_up_at, Time.zone.now)
        for lesson in credit.user.lessons
          unless lesson == credit.lesson
            affiliated_buy = LessonBuyPair.by_lesson(credit.lesson.id).by_other_lesson(lesson.id).first
            if affiliated_buy
              affiliated_buy.update_attributes!(:counter => affiliated_buy.counter + 1)
            else
              pair = LessonBuyPair.create!(:other_lesson => lesson,
                                       :lesson => credit.lesson,
                                       :counter => 1)
            end
          end
        end
      end
    end
  end

  def to_s
    "lesson: #{lesson.id}, other_lesson: #{other_lesson.id}, counter: #{counter}"
  end
end
