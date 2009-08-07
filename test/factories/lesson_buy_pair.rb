Factory.define :lesson_buy_pair do |lesson_buy_pair|
  lesson_buy_pair.association :lesson
  lesson_buy_pair.association :other_lesson, :factory => :lesson
  lesson_buy_pair.counter 10
end