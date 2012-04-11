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
    task :all => [ :truncate, :admins, :users, :seed_skus, :categories, :lessons, :tags, :credits, :acquire_lessons, :reviews, :reset_passwords, :groups, :followers, :tweets ] do
      puts "***** ALL COMPLETE *****"
    end

    desc "Generate some admins"
    task :admins => :environment do
      puts "=== Generating Admins ==="
      require 'populator'
      require 'faker'

      [RolesUser, UserLogon].each(&:delete_all)
      params = { :active => true, :language => 'en', :password => "pa$$word", :password_confirmation => "pa$$word", :password_salt => 'as;fdaslkjasdfn', :time_zone =>Time.zone.name }
      developers_personal_info.each do |dev|
        admin = User.new params
        admin.email = dev[0]
        admin.login = dev[1].downcase
        admin.first_name = dev[1]
        admin.last_name = dev[2]
        admin.user_agreement_accepted_on = Date.today
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

      i = 1
      User.populate count.to_i do |user|
        user.login = "#{Faker::Name.first_name}i"
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
        user.user_agreement_accepted_on = Date.today
        i = i + 1

        # insane why I need to specify these for my PC dev instance -- oh well
        user.rejected_bio = false
        user.show_real_name = true
        user.allow_contact = true
        user.instructor_status = "NO"
        user.withold_taxes = true
        puts "User created: #{user.first_name} #{user.last_name}"
      end
      puts "- done -"
    end

    desc "Generate some lessons"
    task :lessons => :environment do
      APP_CONFIG[CONFIG_S3_DIRECTORY] = ENV['s3_dir']
      puts "=== Generating Lessons ==="
      require 'populator'
      require 'faker'
      puts "S3 root directory: #{APP_CONFIG[CONFIG_S3_DIRECTORY]}"
      blow_away_lessons
      count = ENV['count'] ? ENV['count'] : 21

      (1..count.to_i).each do |i|
        lesson = Lesson.new
        lesson.instructor = User.first(:order => 'RAND()')
        lesson.title = Faker::Company.catch_phrase.titleize[0..49]
        lesson.synopsis = Populator.sentences(2..4)
        lesson.notes = Populator.paragraphs(2..6)
        lesson.status = VIDEO_STATUS_PENDING
        lesson.category = Category.first(:order => "RAND()")
        dummy_video_path = "/test/videos/#{rand(5)+1}.avi" #pick a random vid,
        if !File.exist?(RAILS_ROOT + dummy_video_path)
          puts "can not find file"
        else
          lesson.save!
          video = OriginalVideo.create!(:lesson => lesson,
                                :video => File.open(RAILS_ROOT + dummy_video_path))
          lesson.trigger_conversion("http://some/url")
          puts "#{i}: #{lesson.original_video.video_file_name} uploaded [instructor: #{lesson.instructor.full_name} | file size:#{lesson.original_video.video_file_size}] to #{video.video.path}"
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

      Lesson.all.each do |lesson|
        tags = Tag.all(:order => "RAND()", :limit => rand(6)+1)
        tag_names = tags.collect(&:name)
        lesson.tag_list.add tag_names
        lesson.save!
        puts "#{lesson.id} tagged with #{tag_names.size} tags: #{tag_names.to_sentence}"
      end
    end

    desc "Generate some valid skus"
    task :seed_skus => :environment do
      create_sku CreditSku, CREDIT_SKU, 'Download Credit', 1, 0.99
      create_sku CreditSku, FREE_CREDIT_SKU, 'Free Lesson', 1, 0.0
      create_sku GiftCertificateSku, GIFT_CERTIFICATE_SKU, 'Gift Certificate', 1, 0.99
    end

    desc "Create some followers"
    task :followers => :environment do
      require 'populator'
      require 'faker'
      count = (ENV['count'] ? ENV['count'].to_i : 25)/3
      while User.instructors.count < count
        puts "=============#{User.instructors.count} < #{count}"
        puts "=== Turning some users into instructors ==="
        user = User.first(:order => 'RAND()')
        unless user.verified_instructor? or !user.valid?
          puts "Converting #{user.login} to an instructor"
          user.address1 = Faker::Address.street_address
          user.address2 = Faker::Address.secondary_address
          user.city = Faker::Address.city
          user.state = Faker::Address.us_state
          user.postal_code = Faker::Address.zip_code
          user.country = 'US'
          user.verified_address_on = Time.now
          user.author_agreement_accepted_on = Time.now
          user.payment_level = PaymentLevel.first(:order => 'RAND()')
          user.save!
        end
      end
      puts "=== Generating Followers ==="
      count = (ENV['count'] ? ENV['count'].to_i : 25)
      count.times do |n|
        instructor = User.instructors.first(:order => 'RAND()')
        user = User.first(:order => 'RAND()')
        if instructor.verified_instructor?
          instructor.followers << user unless instructor == user or instructor.followed_by?(user)
        end
      end
    end

    desc "Generate some public groups"
    task :groups => :environment do
      puts "=== Generating Public Groups ==="
      require 'faker'
      require 'populator'

      (1..15).each do |i|
        group = Group.new
        group.owner = User.first(:order => 'RAND()')
        group.category = Category.first(:order => 'RAND()')
        group.private = false
        group.name = Populator.words(1..2)
        group.description = Populator.sentences(2..4)
        unless Group.find_by_name(group.name)
          group.save!
        end
      end
    end

    desc "Generate some tweets"
    task :tweets => :environment do
      puts "=== Generating Tweets ==="
      require 'populator'
      require 'faker'

      (1..20).each do |i|
        tweet = Tweet.new(:search_code => FIREHOZE_TWEETS, :twitter_post_id => Time.now.to_i + i,
                          :iso_language_code => "en")
        tweet.posted_at = (rand() * 10000).to_i.minutes.ago
        tweet.from_user = Faker::Name.name
        tweet.tweet_text = Populator.sentences(1..2)[0..139]
        tweet.profile_image_url = "http://assets.firehoze.com.s3.amazonaws.com/images/users/avatars/tiny/missing.png"
        tweet.save!
      end
    end

    #Not sure I need this any more
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

    #Not sure I neeed this any more
    desc "Generate some categories"
    task :categories => :environment do
      math = create_category "Math", nil, 10
      create_category "Trigonometry", math, 10
      create_category "Calculus", math, 20
      create_category "Geometry", math, 30
      science = create_category "Science", nil, 20
      create_category "Chemistry", science, 10
      create_category "Physics", science, 20
      create_category "Biology", science, 30
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
          if rand(10) + 1 > 7
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
              rating = rand(5) + 1
              lesson.rate(rating, user)
              review = Review.new(:user => user, :headline => Faker::Company.bs.titleize, :body => Populator.paragraphs(1..3))
              lesson.reviews << review
              review.save!

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
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE lesson_attachments;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE activities;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE free_credits;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE group_lessons;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE group_members;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE instructor_follows;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE credits;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE gift_certificates;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE payments;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE line_items;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE order_transactions;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE orders;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE carts;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE helpfuls;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE video_status_changes;")
      ActiveRecord::Base.connection.execute("DELETE FROM videos WHERE converted_from_video_id IS NOT NULL;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE videos;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE lesson_visits;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE discounts;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE skus;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE lesson_buy_pairs;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE lesson_buy_patterns;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE comments;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE wishes;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE flags;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE lessons;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE taggings;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE tags;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE roles_users;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE user_logons;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE user_logons;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE activities;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE groups;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE instructor_follows;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE users;")
    end

    desc "reset all passwords"
    task :reset_passwords => :environment do
      User.all.each do |user|
        user.update_attributes(:password => "123p123p123p", :password_confirmation => "123p123p123p", :password_salt => 'as;fdaslkjasdfn')
      end
    end
  end

  private

  def developers_personal_info
    [["sys@firehoze.com", "admin", "person"], ["rich@firehoze.com", "Rich", "Sturim"], ["bob@firehoze.com", "Bob", "Sturim"]]
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
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 0;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE group_lessons;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE lesson_attachments;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE free_credits;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE credits;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE skus;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE helpfuls;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE reviews;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE video_status_changes;")
    ActiveRecord::Base.connection.execute("DELETE FROM videos WHERE TYPE = 'ProcessedVideo';")
    ActiveRecord::Base.connection.execute("DELETE FROM videos WHERE converted_from_video_id IS NOT NULL;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE videos;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE lesson_visits;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE lessons;")
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 1;")
  end

  def create_category name, parent, sort
    category = Category.find_by_name(name)
    if category
      puts "Category #{category.name} already exists...skipping"
    else
      category = Category.create!(:name => name, :parent_category => parent, :sort_value => sort)
    end
    return category
  end
end
