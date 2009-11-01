Factory.define :topic do |topic|
  topic.association :user
  topic.association :group
  topic.pinned false
  topic.last_commented_at { 1.days.ago }
  topic.title  "This is a title"
end   