Factory.define :flag do |flag|
  flag.status "pending"
  flag.reason_type "Smut"
  flag.comments "Some comments"
  flag.association :user
  flag.association :lesson
end