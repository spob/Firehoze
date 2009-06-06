Factory.define :cart do |cart|
  cart.purchased_at  {|a| 2.days.ago}
  cart.association :user
end