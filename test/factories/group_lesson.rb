Factory.define :group_lesson do |f|
  f.association :user
  f.association :group
  f.association :lesson
end