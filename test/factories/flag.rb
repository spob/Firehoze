Factory.define :flag do |flag|
  flag.status "PENDING"
  flag.flag_type "Smut"
  flag.comments "Some comments"
  flag.association :user
  flag.association :lesson
end