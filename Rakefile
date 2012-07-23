#!/usr/bin/env rake
# -*- coding: utf-8 -*-
#

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', __FILE__)

config = File.expand_path('../../../config/deploy.rb', __FILE__)

require 'bundler/setup'
Bundler.require(:default)

Vlad.load(:app=>'unicorn', :scm => "git", :config => config)

require 'vlad/airbrake'
require 'vlad/rvm'
require 'vlad/delayed_job'
require 'bundler/vlad'

# Rake::RemoteTask.set :git_branch, "production"
# puts "Текущая ветка #{current_branch}"
ENV['DEPLOY_TO'] ||= 'production'

puts "Deploy to: #{ENV['DEPLOY_TO']}"

namespace :vlad do
  def skip_scm; false; end

  if ENV['GIT_BRANCH'] == 'current'
    set :current_branch, `git branch 2>/dev/null | sed -e "/^\s/d" -e "s/^\*\s//"`.chomp
  else
    set :current_branch, 'master'
  end
  # Даетлевые номера, например последних тегов
  #set :current_commit, `git rev-list --all --max-count=1`.chomp
  set :current_commit, `git rev-parse --verify HEAD`.chomp

  set :rails_env, ENV['DEPLOY_TO']
  # Не трогаем апач
  set :web_command, "echo apachectl"

  set :unicorn_command, "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec unicorn"
  set :unicorn_rc, '/etc/init.d/unicorn'

  set :keep_releases,	3
  set :revision, "origin/HEAD/#{current_branch}/#{current_commit}"
  set :rake_cmd, 'bundle exec rake'

  set :git_branch, current_branch

  #set :copy_files, [ 'config/database.yml' ]
  #set :symlinks, copy_files

  set :shared_paths, {
    'log'    => 'log',
    'system' => 'public/system',
    'uploads' => 'public/uploads',
    'pids'   => 'tmp/pids',
    'bundle' => 'vendor/bundle'
  }

  desc "Put revision into public/revision"
  remote_task :put_revision do
    # puts "vlad-git revision: #{source.revision(revision)}"
    airbrake_revision = revision.gsub(/origin.HEAD./,'')
    puts "Put revision.."
    run "cd #{scm_path}/repo;
    export RAILS_ENV=#{rails_env} REVISION=#{airbrake_revision} REPO=#{repository} TO=#{rails_env} USER=`whoami`;
    (nohup ./script/vlad/set_revision #{current_release} 2>&1 >> /tmp/set_revision.log &)"

    has_newrelic = `grep newrelic ./Gemfile`.length>0
    has_newrelic and run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec newrelic deployments -r #{airbrake_revision}"
    # ./script/set_revision #{current_release}"
  end

  # before :"deploy:symlink", :"deploy:assets";
  # rake assets:clean:all RAILS_ENV=production RAILS_GROUPS=assets
  # rm -rf /home/wwwdata/blogs.investcafe.ru/releases/20111127125954/public/assets
  # rake assets:precompile:all RAILS_ENV=production RAILS_GROUPS=assets
  # rake assets:precompile:nondigest RAILS_ENV=production RAILS_GROUPS=assets
  desc 'Precompile assets'
  remote_task :precompile do
    puts "Precompile.."
    symlink_assets = "rm -f #{shared_path}/public; ln -s #{current_release}/public/ #{shared_path}/"
    cmd = "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:clean assets:precompile:primary assets:precompile:nondigest RAILS_ENV=#{rails_env} RAILS_GROUPS=assets"
    run "#{cmd}; #{symlink_assets}"
  end

  remote_task :git_fetch do
    puts "Git fetch.."
    # Когда выполняется первый раз после setup-а, то каталога repo еще не существует
    run "test -d #{scm_path}/repo && (cd #{scm_path}/repo; git fetch) || echo 'no repo'"
  end


  desc 'Umonitor monit'
  remote_task :unmonitor do
    puts 'Unmonitor'
    sudo "monit unmonitor all 2>&1 >> /tmp/monit_restart.log"
  end

  desc 'Monitor monit'
  remote_task :monitor do
    puts 'Monitor'
    sudo "monit monitor all 2>&1 >> /tmp/monit_restart.log"
  end

  desc 'Reindex solr'
  remote_task :solr_reindex do
    puts "Solr reindes"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} nohup time bundle exec rake sunspot:reindex > /tmp/sunspot_reindex.log 2>&1 &"
  end


  namespace :unicorn do

    remote_task :upgrade do
      puts "Upgrade unicorn.."
      sudo "#{unicorn_rc} upgrade"
      puts "Unicorn upgraded"
    end

    remote_task :restart do 
      puts "Restart unicorn.."
      sudo "#{unicorn_rc} restart"
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

  desc 'Влад рассказывает что куда деплоит'
  task :describe do
    vers = `git describe #{current_commit}`.chomp
    puts "Деплоим (#{rails_env}): #{current_branch} / #{current_commit} (#{vers})"
    puts
  end

end

# Однажды
# rake vlad:setup
#
# Когда нужно скопировать database.yml на сервер
# rake vlad:copy     # что-то нету такой задачи
# rake vlad:symlink
#
# Руглярно
# git push
# rake vlad:deploy
