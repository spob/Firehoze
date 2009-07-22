# lib/tasks/populate_fake_data.rake
# Generates test data. Useful for testing and stress testing
# http://railscasts.com/episodes/126
# in order to use this task, you must first install these two gems
# note these should not be part of the environment.rb
# sudo gem install populator
# sudo gem install faker

namespace :db do

  namespace :populate do

    desc "Bootstraps the application"
    task :all => [ :truncate, :admins, :users, :lessons, :tags, :credits, :acquire_lessons, :reviews, :reset_passwords] do
      puts "***** ALL COMPLETE *****"
    end

    desc "Generate some admins"
    task :admins => :environment do
      puts "=== Generating Admins ==="
      require 'populator'
      require 'faker'

      [RolesUser, UserLogon].each(&:delete_all)
      params =  { :active => true, :language => 'en', :password => "pa$$word", :password_confirmation => "pa$$word", :password_salt => 'as;fdaslkjasdfn', :time_zone =>Time.zone.name }
      developers_personal_info.each do |dev|
        admin = User.new params
        admin.email = dev[0]
        admin.login = dev[1].downcase
        admin.first_name = dev[1]
        admin.last_name = dev[2]
        admin.save!
        admin.has_role ROLE_ADMIN
        puts "Admin created: #{admin.full_name}"
      end
      puts "- done -"
    end

    desc "Generate some users"
    task :users => :environment do
      puts "=== Generating Users ==="
      require 'populator'
      require 'faker'

      count = ENV['count'] ? ENV['count'] : 25

      blow_away_lessons

      User.all.each do |user|
        unless user.is_admin?
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
      puts "=== Generating Lessons ==="
      require 'populator'
      require 'faker'
      blow_away_lessons
      count = ENV['count'] ? ENV['count'] : 11

      (1..count.to_i).each do |i|
        lesson = Lesson.new
        lesson.instructor = User.first(:order => 'RAND()')
        lesson.title = Faker::Company.catch_phrase.titleize
        lesson.synopsis = "#{Faker::Company.catch_phrase} #{Faker::Company.catch_phrase}"
        lesson.description = Populator.paragraphs(1..3)
        lesson.status = VIDEO_STATUS_PENDING
        dummy_video_path = "/test/videos/#{rand(5)+1}.avi" #pick a random vid,
        if !File.exist?(RAILS_ROOT + dummy_video_path)
          puts "can not find file"
        else
          lesson.save!
          OriginalVideo.create!(:lesson => lesson,
                                :video => File.open(RAILS_ROOT + dummy_video_path),
                                :format => VIDEO_FORMAT_ORIGINAL)
          lesson.trigger_conversion
          puts "#{i}: #{lesson.original_video.video_file_name} uploaded [instructor: #{lesson.instructor.full_name} | file size:#{lesson.original_video.video_file_size}]"
        end
      end
      puts "- done -"
    end

    desc "Generate some lesson tags"
    task :tags => :environment do
      puts "=== Generating Tags on Lessons ==="
      require 'populator'
      require 'faker'

      Tag.populate 25 do |tag|
        tag.name = Populator.words(1).titleize
        puts "tag created: #{tag.name}"
      end

      Lesson.ready.each do |lesson|
        tags = Tag.all(:order => "RAND()", :limit => rand(6)+1)
        tag_names = tags.collect(&:name)
        lesson.tag_list.add tag_names
        lesson.save!
        puts "#{lesson.id} tagged with #{tag_names.size} tags: #{tag_names.to_sentence}"
      end
    end

    #Not sure I neeed this any more
    desc "Generate some line_items and carts"
    task :carts => :environment do
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
      puts "=== Generating Reviews ==="
      require 'populator'
      require 'faker'

      ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")

      Lesson.all.each do |lesson|
        User.all.each do |user|
          if rand(10) + 1 > 2
            if user.owns_lesson?(lesson) and (user != lesson.instructor)
              review = Review.new(:user => user, :headline => Faker::Company.bs.titleize, :body => Populator.paragraphs(1..3))
              lesson.reviews << review
              review.save!
              rating = rand(5) + 1
              lesson.rate(rating, user)
              puts "Review created by #{user.full_name}: #{review.headline} | rating: #{rating}"
            end
          end
        end
      end
      puts "- done -"
    end

    desc "truncates tables"
    task :truncate => :environment do
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE periodic_jobs;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE credits;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE gift_certificates;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE line_items;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE order_transactions;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE orders;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE carts;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE helpfuls;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE video_status_changes;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE videos;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE lessons;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE taggings;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE tags;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE roles_users;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE user_logons;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE users;")
    end

    desc "reset all passwords"
    task :reset_passwords => :environment do

      params =  { :active => true, :language => 'en', :password => "pa$$word", :password_confirmation => "pa$$word", :password_salt => 'as;fdaslkjasdfn', :time_zone =>Time.zone.name }
      User.all.each do |user|
        user.update_attributes(:password => "pa$$word", :password_confirmation => "pa$$word", :password_salt => 'as;fdaslkjasdfn')
      end
    end
  end

  private

  def developers_personal_info
    [["sys@firehoze.com", "sys", "admin"], ["rich@firehoze.com", "Rich", "Sturim"], ["bob@firehoze.com", "Bob", "Sturim"], ["joel@firehoze.com", "Joel", "Lindheimer"], ["david@firehoze.com", "David", "Otaguro"]]
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
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE credits;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE helpfuls;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE video_status_changes;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE free_credits;")
    ActiveRecord::Base.connection.execute("DELETE FROM videos WHERE TYPE = 'ProcessedVideo';")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE videos;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE lessons;")
  end
end
