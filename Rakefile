#!/usr/bin/env rake
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
