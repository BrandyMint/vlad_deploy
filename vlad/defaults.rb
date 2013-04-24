# -*- coding: utf-8 -*-

namespace :vlad do

  if ENV['GIT_BRANCH'] == 'current'
    set :current_branch, `git branch 2>/dev/null | sed -e "/^\s/d" -e "s/^\*\s//"`.chomp
  else
    set :current_branch, 'master'
  end
  # Даетлевые номера, например последних тегов
  #set :current_commit, `git rev-list --all --max-count=1`.chomp
  set :current_commit, `git rev-parse --verify HEAD`.chomp

  set :rails_env, ENV['to']
  # Не трогаем апач
  set :web_command, "echo apachectl"

  set :keep_releases,	3
  set :rake_cmd, 'bundle exec rake'

  set :git_branch, current_branch

  set :copy_files, [ 'config/database.yml' ]
  set :symlinks, copy_files

  set :shared_paths, {
    'log'     => 'log',
    'system'  => 'public/system',
    'assets'  => 'public/assets',
    'uploads' => 'public/uploads',
    'pids'    => 'tmp/pids',
    'bundle'  => 'vendor/bundle',
    'finam'   => 'tmp/finam'
  }

  set :unicorn_command, "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec unicorn"
  set :revision, "origin/HEAD/#{current_branch}/#{current_commit}"
end
