require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

# Setup environment values
require File.expand_path('lib/ginatra/env', File.dirname(__FILE__))
Ginatra::Env.port = 8080
Ginatra::Env.websocket_port = 9290
Ginatra::Env.root = ::File.expand_path('./', ::File.dirname(__FILE__))
Ginatra::Env.data = ::File.expand_path('data', ::File.dirname(__FILE__))

# The main app will run immediately once included as we wrap the whole app
# inside an eventmachine. Check lib/app.rb
require File.expand_path('lib/ginatra', File.dirname(__FILE__))
