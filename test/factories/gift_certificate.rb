Factory.define :gift_certificate do |gift_certificate|
  gift_certificate.association :user
  gift_certificate.credit_quantity 5
  gift_certificate.price  0.99
  gift_certificate.association :gift_certificate_sku
  gift_certificate.association :line_item
  end

Factory.define :redeemed_gift_certificate, :parent => :gift_certificate do |gift_certificate|
  gift_certificate.association :redeemed_by_user, :factory => :user
  gift_certificate.redeemed_at { 1.days.ago }
end