require 'em-websocket'
require 'eventmachine'
require 'unicorn'
require 'rainbows'

Encoding.default_external = 'utf-8' if RUBY_VERSION =~ /^2.0/

module Ginatra
  class Ginatra
    EM.run {

      # Sinatra App
      class App < Ginatra::API
      end

      # websocket server
      Ginatra::WebsocketServer.start

      # start rainbows
      port = Ginatra::Env.port || 8080
      rackup = Unicorn::Configurator::RACKUP
      rackup[:set_listener] = true
      rackup[:port] = port
      options = rackup[:options]
      options[:config_file] = File.expand_path('./rainbows.conf', Ginatra::API.root)

      Rainbows::HttpServer.new(Ginatra::App, options).start
    }
  end
end
