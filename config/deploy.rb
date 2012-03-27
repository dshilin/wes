set :application, "wesdev"

set :scm, :git
set :repository,  "git://github.com/dshilin/wes.git"

set :user, "hosting_snayp"
set :use_sudo, false
set :deploy_to, "/home/#{user}/projects/wesdev"

role :web, "hydrogen.locum.ru"   # Your HTTP server, Apache/etc
role :app, "hydrogen.locum.ru"   # This may be the same as your `Web` server
role :db,  "hydrogen.locum.ru", :primary => true # This is where Rails migrations will run

set :unicorn_rails, "/var/lib/gems/1.8/bin/unicorn_rails"
set :bundler, "/var/lib/gems/1.8/bin/bundle"
set :rails, "/var/lib/gems/1.8/bin/rails"
set :rake, "/var/lib/gems/1.8/bin/rake"

after "deploy:update_code", :copy_database_config

task :copy_database_config, roles => :app do
  db_config = "#{shared_path}/database.yml"
  run "cp #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{shared_path}/assets #{release_path}/public/assets"
#  run ["cd #{deploy_to}/current",
#       "rvm use ree-1.8.7-2011.03 do bundle install --path ../../shared/gems"].join(" && ")
#       "#{bundler} exec #{rake} werdau_theme:install"].join(" && ")
end

set :unicorn_conf, "/etc/unicorn/wesdev.snayp.rb"
set :unicorn_pid, "/var/run/unicorn/wesdev.snayp.pid"

set :unicorn_start_cmd, "(cd #{deploy_to}/current; rvm use ree-1.8.7-2011.03 do bundle exec unicorn_rails -Dc #{unicorn_conf})"

# - for unicorn - #
namespace :deploy do
  desc "Start application"
  task :start, :roles => :app do
    run ["cd #{deploy_to}/current",
        "rvm use ree-1.8.7-2011.03 do bundle install --path ../../shared/gems",
        unicorn_start_cmd].join(" && ")
  end

  desc "Stop application"
  task :stop, :roles => :app do
    run "[ -f #{unicorn_pid} ] && kill -QUIT `cat #{unicorn_pid}`"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "[ -f #{unicorn_pid} ] && kill -USR2 `cat #{unicorn_pid}` || #{unicorn_start_cmd}"
  end
end

