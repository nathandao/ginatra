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
Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379)

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

    scheduler.every '10s' do
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
      @filter = params.inject({}) { |prms, v|
        prms[v[0].to_sym] = v[1] if [:from, :til, :by, :in, :color].include? v[0].to_sym
        prms[v[0].to_sym] = "##{p[v[0].to_sym]}" if v[0] == 'color'
        prms
      }
      @filter[:color] ||= '#97BBCD'
    end

    get '/stat/hours' do
      Ginatra::Activity.hours(@filter).to_json
    end

    get '/stat/commits' do
      Ginatra::Stat.commits(@filter).to_json
    end

    get '/stat/commits_overview' do
      Ginatra::Stat.commits_overview(@filter).to_json
    end

    get '/stat/repo_overview' do
      Ginatra::Stat.repo_overview(@filter).to_json
    end

    get '/stat/authors' do
      Ginatra::Stat.authors(@filter).to_json
    end

    get '/stat/lines' do
      Ginatra::Stat.lines(@filter).to_json
    end

    get '/stat/chart/round/commits' do
      Ginatra::Chart.rc_commits(@filter).to_json
    end

    get '/stat/chart/round/lines' do
      Ginatra::Chart.rc_lines(@filter).to_json
    end

    get '/stat/chart/round/hours' do
        Ginatra::Chart.rc_hours(@filter).to_json
    end

    get '/stat/chart/round/sprint_commits' do
      Ginatra::Chart.rc_sprint_commits(@filter).to_json
    end

    get '/stat/chart/round/sprint_lines' do
      Ginatra::Chart.rc_sprint_lines(@filter).to_json
    end

    get '/stat/chart/round/sprint_hours' do
      Ginatra::Chart.rc_sprint_hours(@filter).to_json
    end

   get '/stat/chart/line/commits' do
        Ginatra::Chart.lc_commits(@filter).to_json
    end

    get '/stat/chart/line/lines' do
      Ginatra::Chart.lc_lines(@filter).to_json
    end

    get '/stat/chart/line/hours' do
      Ginatra::Chart.lc_hours(@filter).to_json
    end

    get '/stat/chart/line/sprint_hours_commits' do
      Ginatra::Chart.lc_sprint_hours_commits(@filter).to_json
    end

    get '/stat/chart/line/sprint_commits' do
      Ginatra::Chart.lc_sprint_commits(@filter).to_json
    end

    get '/stat/chart/line/sprint_hours' do
      Ginatra::Chart.lc_sprint_hours(@filter).to_json
    end

    get '/stat/chart/timeline/commits' do
      Ginatra::Chart.timeline_commits(@filter).to_json
    end

    get '/stat/chart/timeline/hours' do
      Ginatra::Chart.timeline_hours(@filter).to_json
    end

    get '/stat/chart/timeline/sprint_commits' do
      Ginatra::Chart.timeline_sprint_commits(@filter).to_json
    end

    get '/stat/chart/timeline/sprint_hours' do
      Ginatra::Chart.timeline_sprint_hours(@filter).to_json
    end

    get '/stat/chart/timeline/sprint_hours_commits' do
      Ginatra::Chart.timeline_sprint_hours_commits(@filter).to_json
    end
  end
end
