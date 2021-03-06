# Let's define a sequence that factories can use.  This sequence defines a
# unique e-mail address.  The first address will be "somebody1@example.com",
# and the second will be "somebody2@example.com."
Factory.sequence :email do |n|
  "somebody#{n}@example.com"
end

Factory.sequence :login do |n|
  "login#{n}"
end

Factory.sequence :ptoken do |n|
  "6cde0674657a8a313ce952df979de2830309aa4c11ca65805dd00bfdc65dbcc2f5e36718660a1d2e68c1a08c276d996763985d2f06fd3d076eb7bc4d97b1e3#{n}"
end

Factory.define :user, :default_strategy => :create do |f|
  f.password "xxxxx"
  f.password_confirmation "xxxxx"
  f.first_name "Bob"
  f.last_name "Smith"
  f.login { Factory.next(:login) }
  f.password_salt 'SodiumChloride'
  f.user_agreement_accepted_on { 1.day.ago }
  f.time_zone { Time.zone.name }
  f.crypted_password { |a| Authlogic::CryptoProviders::Sha512.encrypt("xxxxx" + a.password_salt) }
  f.persistence_token { Factory.next(:ptoken) }
  f.perishable_token "xxxx"
  f.email  { Factory.next(:email) }
  f.rejected_bio false
  f.language 'en'
  # f.avatar { ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, 'test', 'images', 'test_image.jpg'), 'image/jpg') }
end
