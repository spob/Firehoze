Factory.define :cart do |cart|
  cart.association :user
end                                             

Factory.define :purchased_cart, :parent => :cart do |cart|
  cart.purchased_at { 1.days.ago } 
end