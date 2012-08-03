# -*- coding: utf-8 -*-

namespace :vlad do
  set :domain, "wwwdata@#{application}"
  set :deploy_to, "/home/wwwdata/stage.#{application}"
  set :unicorn_rc, "/etc/init.d/unicorn-stage.#{application}"
end
