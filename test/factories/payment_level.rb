Factory.define :payment_level do |payment_level|
  payment_level.name "rate"
  payment_level.rate 0.25
  payment_level.default_payment_level true
end