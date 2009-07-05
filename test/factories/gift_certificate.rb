Factory.define :gift_certificate do |gift_certificate|
  gift_certificate.association :user
  gift_certificate.credit_quantity 5
  gift_certificate.price  0.99
  gift_certificate.association :gift_certificate_sku
  gift_certificate.association :line_item
end