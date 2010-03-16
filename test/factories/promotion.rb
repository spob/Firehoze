Factory.sequence :name do |n|
  "promo#{n}"
end

Factory.define :promotion, :class => Promotion do |promotion|
  promotion.code { Factory.next(:name) }
  promotion.promotion_type "PROMO1"
  promotion.expires_at { 20.days.since }
  promotion.description "This is my description"
  promotion.price 0.25
  promotion.credit_quantity 2
end