namespace :registration do
  desc "Generate registration codes"
  task :new => :environment do
    email = ENV['email']
    if email.nil? or email.empty?
      puts "Usage: rake registration:new email=<emailaddress>"
    else
      puts "Generating registration_code for #{email}: #{Registration.formatted_hash(email, HASH_PREFIX, HASH_SUFFIX)}"
    end
  end
end