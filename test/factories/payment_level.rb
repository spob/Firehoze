Factory.sequence :name do |n|
  "name#{n}"
end

Factory.define :payment_level do |p|
  p.sequence(:code) {|n| "code#{n}" }
  p.sequence(:name) {|n| "name#{n}" }
  p.rate 0.25
  p.default_payment_level false
end