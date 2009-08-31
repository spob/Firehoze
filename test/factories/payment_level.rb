Factory.sequence :name do |n|
  "name#{n}"
end

Factory.define :payment_level do |p|
  p.sequence(:name) {|n| "name#{n}" }
  p.code { p.name }
  p.rate 0.25
  p.default_payment_level false
end