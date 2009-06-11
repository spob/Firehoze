Factory.define :line_item do |line_item|
  line_item.association :sku,   :factory => :credit_sku
  line_item.association :cart
  line_item.quantity { APP_CONFIG['min_credit_purchase'] }
  line_item.unit_price 0.99
  line_item.discounted_unit_price 0.99
end