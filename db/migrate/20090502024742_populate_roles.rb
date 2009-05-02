class PopulateRoles < ActiveRecord::Migration
  require 'role_definition'

  def self.up
    admin = User.create :email => 'admin@firehoze.com', :password => "changeme", :password_confirmation => "changeme",
            :first_name => "sys", :last_name => "admin", :password_salt => 'as;fdaslkjasdfn',
            :time_zone =>Time.zone.name
#  f.crypted_password { |a| Authlogic::CryptoProviders::Sha512.encrypt("xxxxx" + a.password_salt) }
    #  f.persistence_token { Factory.next(:ptoken) }
    #  f.perishable_token "xxxx"
    Role.create :name => RoleDefinition::SYSADMIN

    admin.has_role RoleDefinition::SYSADMIN
  end

  def self.down
    Role.find_by_name(RoleDefinition::SYSADMIN).destroy

    User.find_by_email('admin@firehoze.com').destroy
  end
end
