Factory.sequence :name do |n|
  "name#{n}"
end

Factory.sequence :code do |n|
  "code#{n}"
end

Factory.define :payment_level do |payment_level|
  payment_level.code { Factory.next(:code) }
  payment_level.name { Factory.next(:name) }
  payment_level.rate 0.25
  payment_level.default_payment_level true
end