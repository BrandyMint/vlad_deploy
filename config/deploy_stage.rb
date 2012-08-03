# -*- coding: utf-8 -*-

namespace :vlad do
  set :domain, "wwwdata@stage.#{application}"
  set :deploy_to, "/home/wwwdata/stage.#{application}"
end
