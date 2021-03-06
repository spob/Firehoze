namespace :db do
  desc "Populate the database with seed data"
  task :seed => [:seed_users, :seed_jobs, :seed_roles, :seed_skus, :seed_payment_levels]

  desc "Seed the database with users"
  task :seed_users => :environment do
    admin = User.find_by_login('admin')
    admin ||= User.find_by_email('admin@firehoze.com')
    if admin
      puts "User #{admin.login} already exists"
    else
      admin = User.new :password => "changeme", :password_confirmation => "changeme",
                       :first_name => "sys", :last_name => "admin", :password_salt => 'as;fdaslkjasdfn',
                       :time_zone =>Time.zone.name, :user_agreement_accepted_on => Time.now
      admin.login = 'admin'
      admin.email = 'admin@firehoze.com'
      admin.save!
      Role.create! :name => ROLE_ADMIN

      admin.has_role ROLE_ADMIN
    end
  end

  desc "Seed payment levels"
  task :seed_payment_levels do
    create_payment_level('EXCL', 'Exclusive', 0.5, true)
    create_payment_level('NEXCL', 'Non-Exclusive', 0.25, false)
  end

  desc "Seed the database with skus"
  task :seed_skus => :environment do
    create_sku CreditSku, CREDIT_SKU, 'Download Credit', 1, 0.99
    create_sku CreditSku, PROMO_CREDIT_SKU, 'Promo Credit', 1, 0.0
    create_sku CreditSku, FREE_CREDIT_SKU, 'Free Lesson', 1, 0.0
    create_sku GiftCertificateSku, GIFT_CERTIFICATE_SKU, 'Gift Certificate', 1, 0.99
  end

  desc "Seed the database with roles"
  task :seed_roles => :environment do
    create_role(ROLE_PAYMENT_MGR)
    create_role(ROLE_MODERATOR)
    create_role(ROLE_COMMUNITY_MGR)
  end

  desc "Seed the database with periodic jobs"
  task :seed_jobs => :environment do
    create_job RunIntervalPeriodicJob, 'SessionCleaner', 'SessionCleaner.clean', 3600 * 24  #once a day
    create_job RunIntervalPeriodicJob, 'SessionExpiry', 'SessionCleaner.sweep', 1800  #once every 30 minutes
    create_job RunIntervalPeriodicJob, 'ActivityFeed', 'Activity.compile', 1800  #once every 30 minutes
    create_job RunIntervalPeriodicJob, 'TwitterFeed', 'Tweet.fetch_firehoze_tweets("FIREHOZE", "firehoze")', 600  #once every 10 minutes
    create_job RunIntervalPeriodicJob, 'PeriodicJobCleanup', 'PeriodicJob.cleanup', 3600  #once an hour
    create_job RunIntervalPeriodicJob, 'CreditExpiration', 'Credit.expire_unused_credits', 3600 * 24  #once a day
    create_job RunIntervalPeriodicJob, 'LessonBuyPattern', 'LessonBuyPattern.rollup_buy_patterns', 3600  #once an hour
    create_job RunIntervalPeriodicJob, 'LessonBuyPair', 'LessonBuyPair.rollup_buy_patterns', 3600  #once an hour
    create_job RunAtPeriodicJob, 'RebuildIndex', 'system("cd #RAILS_ROOT# && rake thinking_sphinx:index")', nil, 180  # 3AM
  end
end

def create_job(job_class, name, job_command, interval=nil, run_at=nil)
  job = PeriodicJob.find(:first, :conditions => ["name = ? and next_run_at is not null", name])
  if job
    puts "Periodic job #{job.name} already exists"
  else
    job_class.create!(:name => name,
                      :job => job_command,
                      :interval => interval,
                      :run_at_minutes => run_at)
    puts "Created job #{name}"
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

def create_payment_level(code, name, rate, default_payment_level)
  pl = PaymentLevel.find_by_code(code)
  if pl
    puts "Payment level #{code} already exists"
  else
    PaymentLevel.create!(:code => code, :name => name, :rate => rate, :default_payment_level => default_payment_level)
    puts "Created payment level #{code}"
  end
end

def create_role(role_name)
  role = Role.find_by_name(role_name)
  if role
    puts "Role #{role.name} already exists"
  else
    role = Role.create! :name => role_name
    puts "Created role #{role.name}"
  end
end