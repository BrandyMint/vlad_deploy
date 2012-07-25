# -*- coding: utf-8 -*-

namespace :vlad do
  set :application, "brandymint.ru"

  set :revision, "origin/HEAD/#{current_branch}"
  set :domain, "wwwdata@stage.#{application}"
end
