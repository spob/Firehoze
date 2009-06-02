set :application, 'Firehoze'
set :user, 'firehoz'
set :domain, '68.233.8.4'
set :mongrel_port, '4098'
set :server_hostname, '68.233.8.4'
set :keep_releases, 4

set :git_account, 'spob'
set :scm_passphrase,  Proc.new { Capistrano::CLI.password_prompt('F1reh0ze') }

role :web, server_hostname
role :app, server_hostname
role :db, server_hostname, :primary => true

default_run_options[:pty] = true
set :repository,  "git@github.com:spob/Firehoze.git"
set :scm, "git"
set :user, user

ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :use_sudo, false
set :deploy_to, "/home/#{user}/#{application}"

after 'deploy:symlink', 'deploy:finishing_touches', 'deploy:restart', 'mongrel:restart', 'task_server:restart'

namespace :deploy do
  task :finishing_touches, :roles => :app do
    run "cp -pf #{deploy_to}/to_copy/production.rb #{current_path}/config/environments/production.rb"
    run "cp -pf #{deploy_to}/to_copy/database.yml #{current_path}/config/database.yml"
  end

  deploy.task :restart, :roles => :app do
    run "mongrel_rails mongrel::restart -P #{current_path}/tmp/pids/mongrel.pid"
  end
end

namespace :mongrel do
  desc "Start Mongrel"
  task :start, :roles => :app do
    run "mongrel_rails start -e production -p 4098 -d -P #{current_path}/tmp/pids/mongrel.pid -l #{current_path}/log/mongrel.log"
  end

  desc "Restart Mongrel"
  task :restart, :roles => :app do
    run "mongrel_rails restart -P #{current_path}/tmp/pids/mongrel.pid"
    run "ruby #{current_path}/script/task_server_control.rb restart -- -e production"
  end

  desc "Stop Mongrel"
  task :stop, :roles => :app do
    run "mongrel_rails stop -P #{current_path}/tmp/pids/mongrel.pid"
  end
end

namespace :task_server do
  desc "Start Task Server"
  task :start, :roles => :app do
    run "ruby #{current_path}/script/task_server_control.rb start -- -e production"
  end

  desc "Restart Task Server"
  task :restart, :roles => :app do
    run "ruby #{current_path}/script/task_server_control.rb restart -- -e production"
  end

  desc "Stop Task Server"
  task :stop, :roles => :app do
    run "ruby #{current_path}/script/task_server_control.rb stop -- -e production"
  end
end