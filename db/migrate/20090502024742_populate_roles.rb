class PopulateRoles < ActiveRecord::Migration
  require 'constants'

  def self.up
    admin = User.create :email => 'admin@firehoze.com', :password => "changeme", :password_confirmation => "changeme",
            :first_name => "sys", :last_name => "admin", :password_salt => 'as;fdaslkjasdfn',
            :time_zone =>Time.zone.name
#  f.crypted_password { |a| Authlogic::CryptoProviders::Sha512.encrypt("xxxxx" + a.password_salt) }
    #  f.persistence_token { Factory.next(:ptoken) }
    #  f.perishable_token "xxxx"
    Role.create :name => Constants::ROLE_SYSADMIN

    admin.has_role Constants::ROLE_SYSADMIN
  end

  def self.down
    Role.find_by_name(Constants::ROLE_SYSADMIN).destroy

    User.find_by_email('admin@firehoze.com').destroy
  end
end
