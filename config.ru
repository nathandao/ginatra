require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require File.expand_path('lib/ginatra/env', File.dirname(__FILE__))
require File.expand_path('lib/ginatra', File.dirname(__FILE__))

Ginatra::Env.root = ::File.expand_path('.', ::File.dirname(__FILE__))
Ginatra::Env.data = ::File.expand_path('./data/', ::File.dirname(__FILE__))
