Factory.sequence :question do |n|
  "question #{n}"
  end

Factory.define :question do |question|
  question.question { Factory.next(:question) }
  question.association :quiz
end