Factory.define :discount_by_volume, :class => DiscountByVolume do |discount|
  discount.association :sku,   :factory => :credit_sku
  discount.minimum_quantity 5
  discount.percent_discount 0.05
end