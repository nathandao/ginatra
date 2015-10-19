require 'sinatra/assetpack'
require 'sinatra/partial'

require_relative 'api'

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
