require 'em-websocket'
require 'eventmachine'
require 'sinatra/assetpack'
require 'sinatra/partial'
require 'rufus-scheduler'

require_relative 'config'
require_relative 'api'

Encoding.default_external = 'utf-8' if RUBY_VERSION =~ /^2.0/

module Ginatra
  EM.run {

    # Sinatra App
    class App < Ginatra::API

      register Sinatra::AssetPack
      register Sinatra::Partial

      set :data, Ginatra::Env.data || ::File.expand_path('../../data/', ::File.dirname(__FILE__))
      set :root, Ginatra::Env.root || ::File.expand_path('../../', ::File.dirname(__FILE__))
      set :views, File.expand_path('./views', Ginatra::App.root)

      set :partial_template_engine, :erb
      enable :partial_underscores

      assets do
        # Custom assets mangement
        serve '/js', from: 'assets/js'
        serve '/css', from: 'assets/scss'
      end

      get '/css/:stylesheet.css' do
        content_type 'text/css', charset: 'utf-8'
        scss params['stylesheet'].to_sym, :style => :expanded
      end

      get '/' do
        erb :layout, :locals => {:title => Ginatra::Config.title}
      end
    end

    # websocket server
    @clients = []
    EM::WebSocket.start(:host => '0.0.0.0', :port => '9290') do |ws|

      ws.onopen do |handshake|
        @clients << ws
        ws.send "Connected."
      end

      ws.onclose do
        ws.send "Closed."
        @clients.delete ws
        ws = nil
      end

      scheduler = Rufus::Scheduler.new

      scheduler.every '10s' do
        # check for repo updates
      end

      # hit Control + C to stop
      Signal.trap("INT")  { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }
    end

    rackup = Unicorn::Configurator::RACKUP
    rackup[:set_listener] = true
    rackup[:port] = 8080
    options = rackup[:options]
    options[:config_file] = File.expand_path('./rainbows.conf', Ginatra::App.root)

    Rainbows::HttpServer.new(Ginatra::App, options).start
  }
end
