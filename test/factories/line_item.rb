Factory.define :line_item do |line_item|
  line_item.association :sku,   :factory => :credit_sku
  line_item.association :cart
  line_item.quantity 1
  line_item.unit_price 0.99
end