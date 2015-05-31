require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require File.expand_path('lib/ginatra/env', File.dirname(__FILE__))
Ginatra::Env.root = ::File.expand_path('.', ::File.dirname(__FILE__))

require File.expand_path('lib/ginatra/app', File.dirname(__FILE__))
run Ginatra::App
