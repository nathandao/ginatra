require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require File.expand_path('lib/ginatra/env', File.dirname(__FILE__))


Ginatra::Env.port = 9292
Ginatra::Env.websocket_port = 9290

Ginatra::Env.root = ::File.expand_path('', ::File.dirname(__FILE__))
Ginatra::Env.root = ::File.expand_path('', ::File.dirname(__FILE__))
Ginatra::Env.data = ::File.expand_path('data', ::File.dirname(__FILE__))

# The main app will be triggered ant runs immediately once included
# as we are using event machine. Check lib/app.rb
require File.expand_path('lib/ginatra', File.dirname(__FILE__))

