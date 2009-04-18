# Let's define a sequence that factories can use.  This sequence defines a
# unique e-mail address.  The first address will be "somebody1@example.com",
# and the second will be "somebody2@example.com."
Factory.sequence :email do |n|
  "somebody#{n}@example.com"
end


Factory.define :user, :default_strategy => :create do |f|
  f.password "xxxxx"
  f.password_confirmation "xxxxx"
  f.password_salt 'SodiumChloride'
  f.crypted_password { |a| Authlogic::CryptoProviders::Sha512.encrypt("benrocks" + a.password_salt) }
  f.persistence_token "6cde0674657a8a313ce952df979de2830309aa4c11ca65805dd00bfdc65dbcc2f5e36718660a1d2e68c1a08c276d996763985d2f06fd3d076eb7bc4d97b1e317"
  f.email  { Factory.next(:email) }
end