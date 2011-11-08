# -*- coding: utf-8 -*-

# Деплой на личный тестовый
#   rake vlad:deploy
#
# Деплой на продакшен
#   rake vlad:deploy DEPLOY_TO=production
#

ENV['DEPLOY_TO'] ||= 'production'

current_branch = `git branch 2>/dev/null | sed -e "/^\s/d" -e "s/^\*\s//"`.chomp || 'master'

# puts "Текущая ветка #{current_branch}"

namespace :vlad do
  def skip_scm; false; end

  set :application, "blogs.investcafe.ru"

  set :rails_env, ENV['DEPLOY_TO'] || "icf"

  if ENV['DEPLOY_TO']=='production'
    set :revision, 'origin/HEAD/production'
    set :domain, "wwwdata@investcafe.ru"
  else
    set :revision, "origin/HEAD/#{current_branch}"
    set :domain, "wwwdata@icfdev.ru"
  end

  set :deploy_to, "/home/wwwdata/blogs.investcafe.ru"
  set :keep_releases,	3
  set :repository, 'git@github.com:investcafe/blogs.investcafe.ru.git'

  set :copy_files, [ 'config/database.yml' ]
  set :symlinks, copy_files

  set :shared_paths, {
    'log'    => 'log',
    'system' => 'public/system',
    'pids'   => 'tmp/pids',
    'bundle' => 'vendor/bundle'
  }

  set :unicorn_command, "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec unicorn"

  desc "Put revision into public/revision"
  remote_task :put_revision do
    # #{source.revision(revision)}
    airbrake =  "cd #{current_release}; nohup bundle exec rake airbrake:deploy RAILS_ENV=#{rails_env} TO=#{rails_env} REVISION=#{revision} USER=`whoami` REPO=#{repository} >> ./tmp/airbrake_notify.log &"
    run "cd #{scm_path}/repo; git rev-parse HEAD > #{release_path}/public/revision; #{airbrake}"
  end

  # before :"deploy:symlink", :"deploy:assets";
  desc 'Precompile assets'
  remote_task :precompile do
    puts "Precompile.."
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:clean tmp:clear assets:precompile"
  end

  desc 'Restart foreverb'
  remote_task :foreverb do
    puts "Foreverb.."
    run "cd #{current_path}; RAILS_ENV=#{rails_env} nohup bundle exec ./script/foreverb-cron >> ./tmp/forever-restart.log"
  end

  desc 'Load new db/templates and pages'
  remote_task :load_templates_and_pages do
    puts 'Load templates'
    run "cd #{current_path}; RAILS_ENV=#{rails_env} nohup bundle exec rake icf:templates:load icf:pages:load >> ./tmp/load_templates_and_pages.log &"
  end

  set :rake_cmd, 'bundle exec rake'

  namespace :unicorn do

    remote_task :upgrade do
      puts "Upgrade unicorn.."
      sudo "/etc/init.d/unicorn upgrade"
      puts "Unicorn upgraded"
    end

    remote_task :restart do 
      puts "Restart unicorn.."
      sudo "/etc/init.d/unicorn restart"
      puts "Unicorn restart"
    end

  end

  namespace :mybundle do
    set :bundle_without, "development test"

    desc "Execute bundle --deployment" #
    remote_task :install=>['vlad:rvm:trust:release', 'vlad:rvm:trust:current'] do
      # run bundle install with explicit path and without test dependencies
      # С release_path не работает текущая git версия
      run "cd #{current_path}; bundle install --deployment --without #{bundle_without}"
    end
  end

   set :deploy_tasks, %w[
           vlad:update
           vlad:symlink
           vlad:bundle:install
           vlad:migrate
           vlad:put_revision
           vlad:load_templates_and_pages
           vlad:foreverb
           vlad:precompile
           vlad:unicorn:upgrade
           vlad:delayed_job:restart
           vlad:cleanup
   ]
end


# Однажды
# rake vlad:setup
#
# Когда нужно скопировать database.yml на сервер
# rake vlad:copy
# rake vlad:symlink
#
# Руглярно
# git push
# rake vlad:deploy
