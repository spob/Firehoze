Factory.define :credit do |credit|
  credit.association :user
  credit.association :lesson
  credit.association :line_item
  credit.association :sku,  :factory => :credit_sku
  credit.acquired_at {|a| 2.days.ago}
  credit.price 1.00
  credit.redeemed_at {|a| 1.days.ago}
end