require 'rubygems'
require 'bundler/setup'
require 'rainbows'
require 'rack/content_length'
require 'rack/chunked'
require 'eventmachine'

Bundler.require(:default)

require File.expand_path('lib/ginatra/env', File.dirname(__FILE__))
require File.expand_path('lib/ginatra', File.dirname(__FILE__))

# Setup environment values
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

Ginatra::Env.websocket_port = 9290
Ginatra::Env.root = ::File.expand_path('./', ::File.dirname(__FILE__))
Ginatra::Env.data = ::File.expand_path('data', ::File.dirname(__FILE__))

# EM.run {

#   # Sinatra App
#   class App < Ginatra::API
#   end

#   # websocket server
#   Ginatra::WebsocketServer.start

#   # start rainbows
#   rackup = Unicorn::Configurator::RACKUP
#   rackup[:set_listener] = true
#   rackup[:port] = 8080
#   options = rackup[:options]
#   options[:config_file] = File.expand_path('./rainbows.conf', Ginatra::API.root)
#   Rainbows::HttpServer.new(App, options).start
# }

run Ginatra::API
