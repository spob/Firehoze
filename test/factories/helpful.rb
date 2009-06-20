Factory.define :helpful do |helpful|
  helpful.association :user
  helpful.association :review
  helpful.helpful true
end