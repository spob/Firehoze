Factory.define :review do |review|
  review.title "The review title"
  review.body "This is a longer description"
  review.association :user
  review.association :lesson
end