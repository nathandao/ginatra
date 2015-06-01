require 'sinatra/base'
require 'sinatra/assetpack'
require 'json'
require 'sass'

require File.expand_path('env', File.dirname(__FILE__))
require File.expand_path('config', File.dirname(__FILE__))
require File.expand_path('repository', File.dirname(__FILE__))
require File.expand_path('stat', File.dirname(__FILE__))

Encoding.default_external = 'utf-8' if RUBY_VERSION =~ /^1.9/

module Ginatra
  class App < Sinatra::Base
    set :views, File.expand_path('../../views', File.dirname(__FILE__))
    set :haml, { format: :html5 }

    set :root, Ginatra::Env.root

    register Sinatra::AssetPack

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
      erb :layout
    end

    get '/stat/:id/commits' do
      content_type :json
      Ginatra::Stat.commits(params['id']).to_json
    end

    get '/stat/:id/authors' do
      content_type :json
      Ginatra::Stat.authors(params['id']).to_json
    end

    get '/stat/:id/lines' do
      Ginatra::Stat.lines(params['id'])
    end

    get '/stat/all_commits' do
      content_type :json
      Ginatra::Stat.all_commits.to_json
    end

    get '/stat/commits/past/:range' do
      "Hourly commit changes"
    end

  end
end
