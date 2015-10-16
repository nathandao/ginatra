require 'faye/websocket'
require 'permessage_deflate'
require 'rack'
require 'sass'
require 'sinatra/assetpack'
require 'sinatra/base'
require 'sinatra/partial'
require 'yajl/json_gem'

require_relative 'activity'
require_relative 'chart'
require_relative 'config'
require_relative 'env'
require_relative 'helper'
require_relative 'repository'
require_relative 'stat'

Encoding.default_external = 'utf-8' if RUBY_VERSION =~ /^2.0/

module Ginatra

  # Need this since faye-websocket and Rack::Lint does not
  # work well together
  class Rack::Lint::HijackWrapper
    def to_int
      @io.to_i
    end
  end

  class App < Sinatra::Base

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

    # WebSocket repos updates stream
    get '/stream' do
      if Faye::WebSocket.websocket?(request.env)
        ws = Faye::WebSocket.new(request.env)

        # Only the event machine backend websocket client is sending messages
        # regarding repositories that hae changes. The server then sends this
        # message to all the connecting clients.
        ws.on :message do |event|
          ws.send(event.data)
        end

        ws.on :close do |event|
          p [:close, event.code, event.reason]
          ws = nil
        end
      end
    end

    get '/css/:stylesheet.css' do
      content_type 'text/css', charset: 'utf-8'
      scss params['stylesheet'].to_sym, :style => :expanded
    end

    get '/' do
      erb :layout, :locals => {:title => "TEST"}
    end

    before '/stat/*' do
      content_type 'application/json'
      @filter = params.inject({}) { |prms, v|
        if [:from, :til, :by, :in, :color, :labels,
          :time_stamps].include? v[0].to_sym
          prms[v[0].to_sym] = v[1] 
        end
        prms[v[0].to_sym] = "##{p[v[0].to_sym]}" if v[0] == 'color'
        prms
      }
      @filter[:color] ||= '#97BBCD'
    end

    get '/stat/repo_list' do
      Ginatra::Config.repositories.to_json
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
