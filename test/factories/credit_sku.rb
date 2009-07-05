Factory.sequence :sku do |n|
  "sku#{n}"
end

Factory.define :credit_sku, :class => CreditSku do |f|
  f.sku { Factory.next(:sku) }
  f.description "This is a longer description"
  f.num_credits 1
  f.price 1.00
end

Factory.define :gift_certificate_sku, :class => GiftCertificateSku do |f|
  f.sku { Factory.next(:sku) }
  f.description "This is a longer description"
  f.num_credits 1
  f.price 0.99
end