namespace :db do
  desc "Populate the database with seed data"
  task :seed => [:seed_users, :seed_jobs, :roles]

  desc "Seed the database with users"
  task :seed_users => :environment do
    admin = User.find_by_login('admin')
    if admin
      puts "User #{admin.login} already exists"
    else
      admin = User.new :password => "changeme", :password_confirmation => "changeme",
                       :first_name => "sys", :last_name => "admin", :password_salt => 'as;fdaslkjasdfn',
                       :time_zone =>Time.zone.name
      admin.login = 'admin'
      admin.email = 'admin@firehoze.com'
      admin.save!
      Role.create! :name => ROLE_SYSADMIN

      admin.has_role ROLE_SYSADMIN
    end
  end

  desc "Seed the database with roles"
  task :roles => :environment do
    role = Role.find_by_name(ROLE_MODERATOR)
    if role
      puts "Role #{role.name} already exists"
    else
      Role.create! :name => ROLE_MODERATOR
    end
  end

  desc "Seed the database with periodic jobs"
  task :seed_jobs => :environment do
    job = PeriodicJob.find_by_name('SessionCleaner')
    if job
      puts "Periodic job #{job.name} already exists"
    else
      RunIntervalPeriodicJob.create(:name => 'SessionCleaner',
                                    :job => 'SessionCleaner.clean',
                                    :interval => 3600 * 24) #once a day
    end

    job = PeriodicJob.find_by_name('PeriodicJobCleanup')
    if job
      puts "Periodic job #{job.name} already exists"
    else
      RunIntervalPeriodicJob.create(:name => 'PeriodicJobCleanup',
                                    :job => 'PeriodicJob.cleanup', :interval => 3600) #once an hour
    end

    job = PeriodicJob.find_by_name('CreditExpiration')
    if job
      puts "Periodic job #{job.name} already exists"
    else
      RunIntervalPeriodicJob.create(:name => 'CreditExpiration',
                                    :job => 'Credit.expire_unused_credits',
                                    :interval => 3600 * 24) #once a day
    end
  end
end