Factory.define :order do |order|
  order.association :cart
  order.association :user
  order.ip_address "192.168.1.1" 
  order.billing_name "Jim Smith"
  order.address1 "123 Main St."
  order.city "New York"
  order.state "NY"
  order.country "US"
  order.zip "10001"
  order.card_type 'visa'
  order.card_number '4024007148673576'
  order.card_verification '888'
  order.card_expires_on { 5.years.since }
  order.first_name "Jim"
  order.last_name "Smith"
end

Factory.define :completed_order, :parent => :order do |order|
  order.association :cart, :factory => :purchased_cart
end

