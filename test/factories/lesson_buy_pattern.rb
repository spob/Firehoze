Factory.define :lesson_buy_pattern do |lesson_buy_pattern|
  lesson_buy_pattern.association :lesson
  lesson_buy_pattern.association :purchased_lesson, :factory => :lesson
  lesson_buy_pattern.counter 10
end