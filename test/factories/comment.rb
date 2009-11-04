Factory.define :comment do |comment|
  comment.association :user
  comment.public true
  comment.status 'active'
  comment.body  "This is a body of a comment"
end                                             

Factory.define :lesson_comment, :class => LessonComment, :parent => :comment do |comment|
  comment.association :lesson
end                                              

Factory.define :topic_comment, :class => TopicComment, :parent => :comment do |c|
  c.topic {|a| a.association(:topic) }
end