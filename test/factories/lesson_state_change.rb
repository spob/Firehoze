Factory.define :lesson_state_change do |lesson_state_change|
  lesson_state_change.association :lesson
  lesson_state_change.from_state 'pending'
  lesson_state_change.to_state 'converting'
end