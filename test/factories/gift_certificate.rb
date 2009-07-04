Factory.define :gift_certificate do |gift_certificate|
  gift_certificate.association :user
  gift_certificate.credit_quantity 5
end