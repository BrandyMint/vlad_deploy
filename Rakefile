#!/usr/bin/env rake
# -*- coding: utf-8 -*-
#

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', __FILE__)

require 'bundler/setup'
Bundler.require(:default)

# Rake::RemoteTask.set :git_branch, "production"
current_branch = `git branch 2>/dev/null | sed -e "/^\s/d" -e "s/^\*\s//"`.chomp || 'master'
puts "Текущая ветка #{current_branch}"

ENV['DEPLOY_TO'] ||= 'production'

puts "Deploy to: #{ENV['DEPLOY_TO']}"

config = File.expand_path('../../../config/deploy.rb', __FILE__)
Vlad.load :app=>'unicorn', :scm => "git", :config => config

require 'vlad/airbrake'
require 'tasks'
require 'vlad/rvm'
require 'vlad/delayed_job'
require 'bundler/vlad'

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
