# -*- coding: utf-8 -*-

# Деплой на личный тестовый
#   rake vlad:deploy
#
# Деплой на продакшен
#   rake vlad:deploy DEPLOY_TO=production
#

namespace :vlad do
  require './script/vlad/config_before'

  set :application, "brandymint.ru"

  if ENV['DEPLOY_TO']=='production'
    set :revision, 'origin/HEAD/production'
    set :domain, "wwwdata@#{application}"
  elsif ENV['DEPLOY_TO']=='stage'
    set :revision, "origin/HEAD/#{current_branch}"
    set :domain, "wwwdata@stage.#{application}"
  end

  set :deploy_to, "/home/wwwdata/#{application}"
  set :unicorn_rc, "/etc/init.d/unicorn-#{application}"
  set :repository, "git@github.com:BrandyMint/#{application}.git"

  set :deploy_tasks, %w[
           vlad:update
           vlad:symlink
           vlad:bundle:install
           vlad:migrate
           vlad:put_revision
           vlad:precompile
           vlad:unicorn:upgrade
           vlad:cleanup
   ]


   # Long story
   #
   #set :deploy_tasks, %w[
           #vlad:update
           #vlad:symlink
           #vlad:bundle:install
           #vlad:migrate
           #vlad:put_revision
           #vlad:foreverb
           #vlad:precompile
           #vlad:unicorn:upgrade
           #vlad:delayed_job:restart
           #vlad:cleanup
   #]
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
