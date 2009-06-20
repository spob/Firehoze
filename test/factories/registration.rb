# Let's define a sequence that factories can use.  This sequence defines a
# unique e-mail address.  The first address will be "somebody1@example.com",
# and the second will be "somebody2@example.com."
Factory.sequence :email do |n|
  "somebody#{n}@example.com"
end

Factory.sequence :username do |n|
  "user#{n}"
end


Factory.define :registration do |f|
  f.username { Factory.next(:username) }
  f.email  { Factory.next(:email) }
end                             