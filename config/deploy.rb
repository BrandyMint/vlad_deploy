# -*- coding: utf-8 -*-

# Деплой на личный тестовый
#   rake vlad:deploy
#
# Деплой на продакшен
#   rake vlad:deploy to=production
#
require './script/vlad/vlad/defaults'

namespace :vlad do
  set :revision, 'origin/HEAD/production'
  set :application, "brandymint.ru"

  set :repository, "git@github.com:BrandyMint/#{application}.git"

  set :deploy_tasks, %w[
           vlad:update
           vlad:symlink
           vlad:bundle:install
           vlad:migrate
           vlad:put_revision
           vlad:precompile_assets
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
