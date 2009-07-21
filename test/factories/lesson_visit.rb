Factory.define :lesson_visit do |lesson_visit|
  lesson_visit.session_id "session_idasdfasafsd"
  lesson_visit.association :user
  lesson_visit.association :lesson
  lesson_visit.visited_at { 2.minutes.ago }
end