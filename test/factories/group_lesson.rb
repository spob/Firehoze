Factory.define :group_lesson do |f|
  f.association :user
  f.association :group
  f.association :lesson
  f.notes "This is a longer note"
end