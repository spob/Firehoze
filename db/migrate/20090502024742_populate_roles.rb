class PopulateRoles < ActiveRecord::Migration
  require 'constants'

  def self.up
    admin = User.new :password => "changeme", :password_confirmation => "changeme",
            :first_name => "sys", :last_name => "admin", :password_salt => 'as;fdaslkjasdfn',
            :time_zone =>Time.zone.name
    admin.login = 'admin'
    admin.email = 'admin@firehoze.com'
    admin.save!
    Role.create! :name => ROLE_SYSADMIN

    admin.has_role ROLE_SYSADMIN
  end

  def self.down
    puts "Destroy role..."
    Role.find_by_name(ROLE_SYSADMIN).destroy
    puts "done"

    puts "Destroy user..."
    User.find_by_email('admin@firehoze.com').delete
    puts "done"
  end
end