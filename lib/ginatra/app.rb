require 'sinatra/base'
require 'sinatra/assetpack'
require 'rufus/scheduler'
require 'yajl'
require 'yajl/json_gem'
require 'sass'

require File.expand_path('env', File.dirname(__FILE__))
require File.expand_path('config', File.dirname(__FILE__))
require File.expand_path('helper', File.dirname(__FILE__))
require File.expand_path('repository', File.dirname(__FILE__))
require File.expand_path('stat', File.dirname(__FILE__))
require File.expand_path('activity', File.dirname(__FILE__))
require File.expand_path('chart', File.dirname(__FILE__))

Encoding.default_external = 'utf-8' if RUBY_VERSION =~ /^1.9/

module Ginatra
  class App < Sinatra::Base
    register Sinatra::AssetPack

    set :views, File.expand_path('../../views', File.dirname(__FILE__))
    set :root, Ginatra::Env.root
    set :data, Ginatra::Env.data

    assets do
      # Custom assets mangement
      serve '/js', from: 'assets/js'
      serve '/css', from: 'assets/scss'
    end

    scheduler = Rufus::Scheduler.new

    scheduler.every '3m' do
      Ginatra::Stat.refresh_all_data
    end

    get '/' do
      erb :layout
    end

    get '/css/:stylesheet.css' do
      content_type 'text/css', charset: 'utf-8'
      scss params['stylesheet'].to_sym, :style => :expanded
    end

    before '/stat/*' do
      content_type 'application/json'
      @filter = params.inject({}) { |p, v|
        p[v[0].to_sym] = v[1] if [:from, :til, :by, :in].include? v[0].to_sym
        p
      }
    end

    get '/stat/hours' do
      Ginatra::Activity.hours(@filter).to_json
    end

    get '/stat/commits' do
      Ginatra::Stat.commits(@filter).to_json
    end

    get '/stat/authors' do
      Ginatra::Stat.authors(@filter).to_json
    end

    get '/stat/lines' do
      Ginatra::Stat.lines(@filter)
    end

    get '/stat/chart/commits' do
      Ginatra::Chart.rc_commits(@filter).to_json
    end
  end
end
