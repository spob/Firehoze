if ENV['DEPLOY'] == 'PRODUCTION'
  puts "*** Deploying to the \033[1;41m  PRODUCTION  \033[0m servers!"
  set :domain, '208.88.124.16'
  set :branch, "master"
else
  puts "*** Deploying to the \033[1;42m  STAGING  \033[0m server!"
  set :domain, '208.88.125.156'
  set :branch, "staging"
end
set :user, 'root'
set :base_dir, 'rails'
set :application, 'Firehoze'
set :rails_env, 'production'
set :server_hostname, domain
set :keep_releases, 8
after "deploy:update", "deploy:cleanup"


set :runner, user

set :git_account, 'spob'
set :scm_passphrase, Proc.new { Capistrano::CLI.password_prompt('F1reh0ze') }

role :web, server_hostname
role :app, server_hostname
role :db, server_hostname, :primary => true

default_run_options[:pty] = true
set :repository, "git@github.com:spob/Firehoze.git"
set :scm, :git
#set :user, user

ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :use_sudo, false
set :deploy_to, "/var/#{base_dir}/#{application}"

before 'deploy:update', 'deploy:web:disable'
after 'deploy:update', 'deploy:finishing_touches', 'deploy:migrate', 'task_server:restart', 'deploy:web:enable'

task :after_cold, :roles => [:app, :web, :db] do
  run "chown -R www-data:www-data /var/#{base_dir}/#{application}"
end

task :before_update, :roles => [:app] do
  # Stop Thinking Sphinx before the update so it finds its configuration file.
  thinking_sphinx.stop
end

task :after_update, :roles => [:app] do
  files.cleanup
  symlink_sphinx_indexes
  thinking_sphinx.configure
  thinking_sphinx.rebuild
end

desc "Link up Sphinx's indexes."
task :symlink_sphinx_indexes, :roles => [:app] do
  run "ln -nfs #{shared_path}/sphinx #{current_path}/db/sphinx"
end

task :after_deploy, :roles => [:app, :web, :db] do
  run "chown -R www-data:www-data /var/#{base_dir}/#{application}"
#  run "chmod -R 777 #{current_path}/public/stylesheets/v2"
# run "cd #{current_path}; rake more:parse RAILS_ENV=#{rails_env}"
end

# Thinking Sphinx
namespace :thinking_sphinx do
  task :configure, :roles => [:app] do
    run "cd #{current_path}; rake thinking_sphinx:configure RAILS_ENV=#{rails_env}"
  end
  task :index, :roles => [:app] do
    run "cd #{current_path}; rake thinking_sphinx:index RAILS_ENV=#{rails_env}"
  end
  task :start, :roles => [:app] do
    run "cd #{current_path}; rake thinking_sphinx:start RAILS_ENV=#{rails_env}"
  end
  task :stop, :roles => [:app] do
    run "cd #{current_path}; rake thinking_sphinx:stop RAILS_ENV=#{rails_env}"
  end
  task :restart, :roles => [:app] do
    run "cd #{current_path}; rake thinking_sphinx:restart RAILS_ENV=#{rails_env}"
  end
  task :rebuild, :roles => [:app] do
    run "cd #{current_path}; rake thinking_sphinx:rebuild RAILS_ENV=#{rails_env}"
  end
end

namespace :files do
  task :cleanup, :roles => [:app] do
    run "rake log:clear RAILS_ENV=production -f #{current_path}/Rakefile"
    run "chmod -R 777 #{current_path}/tmp/cache"
  end
end

namespace :deploy do
  task :finishing_touches, :roles => :app do
    run "cp -pf #{deploy_to}/to_copy/production.rb #{current_path}/config/environments/production.rb"
    run "cp -pf #{deploy_to}/to_copy/database.yml #{current_path}/config/database.yml"
    run "cp -pf #{deploy_to}/to_copy/sphinx.yml #{current_path}/config/sphinx.yml"
    run "cp -pf #{deploy_to}/to_copy/newrelic.yml #{current_path}/config/newrelic.yml"
    run "cp -pf #{deploy_to}/to_copy/production.yml #{current_path}/config/environments/production.yml"
    run "cp -pf #{deploy_to}/to_copy/facebooker.yml #{current_path}/config/facebooker.yml"
    if ENV['DEPLOY'] == 'PRODUCTION'
      run "cp -pf #{deploy_to}/to_copy/sitemap.xml #{current_path}/public/sitemap.xml"
      run "cp -pf #{deploy_to}/to_copy/robots.txt #{current_path}/public/robots.txt"
      run "cp -pf #{deploy_to}/to_copy/LiveSearchSiteAuth.xml #{current_path}/public/LiveSearchSiteAuth.xml"
      run "cp -pf #{deploy_to}/to_copy/y_key_40c2095448e3cc9d.html #{current_path}/public/y_key_40c2095448e3cc9d.html"
    else
      # nothing for now
    end
    # run "rm #{current_path}/lib/tasks/populate_fake_data.rake"
    # preserve the assets directory which resides under shared
    # run "ln -s #{shared_path}/assets #{release_path}/public/assets" 
  end

  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

#namespace :mongrel do
#  desc "Start Mongrel"
#  task :start, :roles => :app do
#    run "mongrel_rails start -e production -p 4098 -d -P /home/firehoz/Firehoze/shared/pids/mongrel.pid -l #{current_path}/log/mongrel.log -c #{current_path}"
#  end
#
#  desc "Restart Mongrel"
#  task :restart, :roles => :app do
#    run "mongrel_rails restart -P /home/firehoz/Firehoze/shared/pids/mongrel.pid"
#    #run "ruby #{current_path}/script/task_server_control.rb restart -- -e production"
#  end
#
#  desc "Stop Mongrel"
#  task :stop, :roles => :app do
#    run "mongrel_rails stop -P /home/firehoz/Firehoze/shared/pids/mongrel.pid"
#  end
#end

namespace :task_server do
  desc "Start Task Server"
  task :start, :roles => :app do
    puts "Starting task server"
    run "ruby #{current_path}/script/task_server_control.rb start -- -e production"
    puts "Done"
  end

  desc "Restart Task Server"
  task :restart, :roles => :app do
    puts "Restarting task server"
    run "ruby #{current_path}/script/task_server_control.rb restart -- -e production"
    puts "Task server restart complete"
  end

  desc "Stop Task Server"
  task :stop, :roles => :app do
    puts "Stopping task server"
    run "ruby #{current_path}/script/task_server_control.rb stop -- -e production"
    puts "Done"
  end
end

namespace :database do
  desc "Reset the database"
  task :reset do
    run "rake db:migrate:reset RAILS_ENV=production -f #{current_path}/Rakefile"
    run "rm -rf  #{shared_path}/assets/videos"
  end
#  task :down do
#    run "rake db:migrate RAILS_ENV=production VERSION=20081103171327 -f #{current_path}/Rakefile"
#    run "rm -rf  #{shared_path}/assets/videos"
#  end
end

namespace :gems do
  desc "Show installed gems"
  task :list do
    stream "gem list"
  end
  task :install do
    run "rake gems:install"
  end
end

task :uptime, :roles => [ :app, :web, :db ] do
  run 'uptime'
end

task :tail_log, :roles => [ :app ] do
  log_file = "#{shared_path}/log/production.log"
  run "tail -f #{log_file}" do |channel, stream, data|
    puts data if stream == :out
    if stream == :err
      puts "[Error: #{channel[:host]}] #{data}"
      break
    end
  end
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
