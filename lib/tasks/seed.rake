namespace :db do
  desc "Populate the database with seed data"
  task :seed => [:seed_users, :seed_jobs, :seed_roles, :seed_skus]

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

  desc "Seed the database with skus"
  task :seed_skus => :environment do
    create_sku CreditSku, CREDIT_SKU, 'Download Credit', 1, 0.99
    create_sku CreditSku, FREE_CREDIT_SKU, 'Free Lesson', 1, 0.0
    create_sku GiftCertificateSku, GIFT_CERTIFICATE_SKU, 'Gift Certificate', 1, 0.99
  end

  desc "Seed the database with roles"
  task :seed_roles => :environment do
    role = Role.find_by_name(ROLE_MODERATOR)
    if role
      puts "Role #{role.name} already exists"
    else
      Role.create! :name => ROLE_MODERATOR
    end
  end

  desc "Seed the database with periodic jobs"
  task :seed_jobs => :environment do
    create_job RunIntervalPeriodicJob, 'SessionCleaner', 'SessionCleaner.clean', 3600 * 24  #once a day
    create_job RunIntervalPeriodicJob, 'PeriodicJobCleanup', 'PeriodicJob.cleanup', 3600  #once an hour
    create_job RunIntervalPeriodicJob, 'CreditExpiration', 'Credit.expire_unused_credits', 3600 * 24  #once a day
  end
end

def create_job job_class, name, job, internal
  job = PeriodicJob.find_by_name(name)
  if job
    puts "Periodic job #{job.name} already exists"
  else
    job_class.create!(:name => name,
                      :job => job,
                      :interval => interval)
    puts "Created job #{job.name}"
  end
end

def create_sku sku_class, sku_name, description, credits, price
  sku = Sku.find_by_sku(sku_name)
  if sku
    puts "Sku #{sku.sku} already exists"
  else
    sku = sku_class.create!(:sku => sku_name, :description => description,
                            :num_credits => credits, :price => price)
    puts "Sku #{sku.sku} created"
  end
end