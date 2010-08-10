Factory.sequence :name do |n|
  "description #{n}"
  end

Factory.define :quiz do |quiz|
  quiz.name { Factory.next(:name) }
  quiz.description "some description"
  quiz.association :group
end