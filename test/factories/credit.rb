Factory.define :credit do |credit|
  credit.association :user
  credit.association :video
  credit.association :sku,  :factory => :credit_sku
  credit.acquired_at {|a| 2.days.ago}
  credit.expires_at {|a| 1.year.from_now}
  credit.price 1.00
  credit.redeemed_at {|a| 1.days.ago}
end