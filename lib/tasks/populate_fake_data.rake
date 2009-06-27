# lib/tasks/populate_fake_data.rb
# generates test data, useful for testing and stress testing
# http://railscasts.com/episodes/126
# in order to user this task, you must first install these two gems
# notet these should be part of the environment.rb
# sudo gem install populator
# sudo gem install faker

namespace :db do

  namespace :populate do

    desc "Bootstraps the application"
    raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
    task :all => [:truncate, :admins, :users, :lessons, :credits, :acquire_lessons, :reviews] do
      puts "***** ALL COMPLETE *****"
    end

    desc "Generate some admins"
    task :admins => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      puts "=== Generating Admins ==="
      require 'populator'
      require 'faker'

      [RolesUser, UserLogon].each(&:delete_all)
      params =  { :active => true, :language => 'en', :password => "changeme", :password_confirmation => "changeme", :password_salt => 'as;fdaslkjasdfn', :time_zone =>Time.zone.name }
      developers_personal_info.each do |dev|
        admin = User.new params
        admin.email = dev[0]
        admin.login = dev[1]
        admin.first_name = dev[1]
        admin.last_name = dev[2]
        admin.save!
        admin.has_role Constants::ROLE_SYSADMIN
        puts "Admin created: #{admin.full_name}"
      end
      puts "- done -"
    end

    desc "Generate some users"
    task :users => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      puts "=== Generating Users ==="
      require 'populator'
      require 'faker'

      count = ENV['count'] ? ENV['count'] : 25

      blow_away_lessons

      User.all.each do |user|
        unless user.is_sysadmin?
          user.destroy
        end
      end

      User.populate count.to_i do |user|
        user.login = Faker::Name.first_name + Faker::Name.last_name
        user.first_name = Faker::Name.first_name
        user.last_name = Faker::Name.last_name
        user.email = Faker::Internet.email
        user.crypted_password = "foobar"
        user.password_salt = "foobar"
        user.persistence_token = "foobar"
        user.perishable_token = "foobar"
        user.language = 'en'
        user.time_zone = Time.zone.name
        user.login_count = 0
        user.failed_login_count = 0
        user.active = true
        puts "User created: #{user.first_name} #{user.last_name}"
      end
      puts "- done -"
    end

    desc "Generate some lessons"
    task :lessons => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      puts "=== Generating Lessons ==="
      require 'populator'
      require 'faker'
      blow_away_lessons
      count = ENV['count'] ? ENV['count'] : 10

      (1..count.to_i).each do |i|
        lesson = Lesson.new
        lesson.instructor = User.first(:order => 'RAND()')
        lesson.title = Faker::Company.catch_phrase.titleize
        lesson.description = Populator.paragraphs(1..3)
        lesson.state = "ready"
        dummy_video_path = "/test/videos/#{rand(5)+1}.swf" #pick a random vid,
        if !File.exist?(RAILS_ROOT + dummy_video_path)
          puts "can not find file"
        else
          lesson.video = File.open(RAILS_ROOT + dummy_video_path)
          lesson.save!
          puts "#{i}: #{lesson.video_file_name} uploaded [instructor: #{lesson.instructor.full_name} | file size:#{lesson.video_file_size}]"
        end
      end
      puts "- done -"
    end

    #Not sure I neeed this any more
    desc "Generate some line_items and carts"
    task :carts => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      sku = Sku.first
      User.all.each do |user|
        cart = Cart.new(:user => user)
        line_item = LineItem.new(:quantity => 10, :unit_price => sku.price)
        line_item.sku = sku
        line_item.cart = cart
        line_item.save!
      end
    end

    desc "Generate some credits"
    task :credits => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      puts "=== Generating Credits ==="
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE credits;")

      count = ENV['count'] ? ENV['count'] : 10

      User.all.each do |user|
        count.to_i.times { user.credits.create!(:price => 0.99) }
      end
      puts "- done -"
    end

    desc "Acquire some lessons"
    task :acquire_lessons => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      puts "=== Acquiring Lessons ==="

      Lesson.all(:order => "RAND()").each do |lesson|
        User.all.each do |user|
          if rand(10) + 1 > 3
            unless user.available_credits.empty?
              credit = user.available_credits.first
              credit.update_attributes(:lesson => lesson, :acquired_at => Time.now)
            end
          end
        end
      end
      puts "- done -"
    end

    desc "Generate some reviews"
    task :reviews => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      puts "=== Generating Reviews ==="
      require 'populator'
      require 'faker'

      ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")

      Lesson.all.each do |lesson|
        User.all.each do |user|
          if rand(10) + 1 > 2
            if user.owns_lesson?(lesson) and (user != lesson.instructor)
              review = Review.new(:user => user, :title => Faker::Company.bs.titleize,:body => Populator.paragraphs(1..3))
              lesson.reviews << review
              review.save!
              puts "Review created by #{user.full_name}: #{review.title}"
            end
          end
        end
      end
      puts "- done -"      
    end

    desc "truncates tables"
    raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
    task :truncate => :environment do
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE credits;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE line_items;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE carts;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE lessons;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE roles_users;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE user_logons;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE users;")
    end
  end

  private

  def developers_personal_info
    [["admin@firehoze.com", "sys", "admin"], ["rich@firehoze.com", "Rich", "Sturim"], ["bob@firehoze.com", "Bob", "Sturim"], ["joel@firehoze.com", "Joel", "Lindheimer"], ["david@firehoze.com", "David", "Otaguro"]]
  end

  def developers
    developers = []
    developers_emails.each do |email|
      developers << User.find_by_email(email)
    end
    developers
  end

  def developer_emails
    %w(rich@firehoze.com bob@firehoze.com joel@firehoze.com david@firehoze.com)
  end

  def blow_away_lessons
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE credits;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE lessons;")
  end
end
