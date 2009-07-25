Factory.define :comment do |cart|
  cart.association :user
  cart.public true
  cart.body  "This is a body of a comment"
end                                             

Factory.define :lesson_comment, :class => LessonComment, :parent => :comment do |cart|
  cart.association :lesson
end