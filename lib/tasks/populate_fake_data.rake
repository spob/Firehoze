# lib/tasks/populate_fake_data.rb
# generates test data, useful for testing and stress testing
# http://railscasts.com/episodes/126
# in order to user this task, you must first install these two gems
# notet these should be part of the environment.rb
# sudo gem install populator
# sudo gem install faker

namespace :db do

  namespace :populate do
    desc "Erase and fill database with useful conservation recommendation related data"

    desc "Generate some admins"
    task :admins => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      require 'populator'
      require 'faker'

      [RolesUser, UserLogon].each(&:delete_all)
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE users;")

      params =  { :active => true, :language => 'en', :password => "changeme", :password_confirmation => "changeme", :password_salt => 'as;fdaslkjasdfn', :time_zone =>Time.zone.name }
      developers_personal_info.each do |dev|
        admin = User.new params 
        admin.email = dev[0]
        admin.login = dev[1]
        admin.first_name = dev[1]
        admin.last_name = dev[2]
        admin.save!
        admin.has_role Constants::ROLE_SYSADMIN
      end
    end

    desc "Generate some users"
    task :users => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      require 'populator'
      require 'faker'

      User.all.each do |user|
        if !User.first.roles.include?(Role.find_by_name('sysadmin'))
          user.destroy
        end
      end

      User.populate 100 do |user|
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
      end
    end

    desc "Generate some lessons"
    task :lessons => :environment do
      raise "******** Stop! This is only for development or test environments." unless %w(development test).include?(RAILS_ENV)
      require 'populator'
      require 'faker'

      (1..5).each do |i|
        lesson = Lesson.new 
        lesson.instructor = User.first(:order => 'RAND()')
        lesson.title = Populator.words(1..4).titleize
        lesson.description = Populator.paragraphs(1..3)
        lesson.state = "ready"
        dummy_video_path = "/test/videos/#{i}.swf"
        if !File.exist?(RAILS_ROOT + dummy_video_path)
          puts "can not find file"
        else
          lesson.video = File.open(RAILS_ROOT + dummy_video_path)
          lesson.save!
          puts "done"
        end
      end

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

end
