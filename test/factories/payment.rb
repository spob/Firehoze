Factory.define :payment do |p|
  p.amount 0.25
  p.association :user
end