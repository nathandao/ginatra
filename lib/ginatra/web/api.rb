require 'sinatra/base'
require 'sinatra/cross_origin'

module Ginatra
  class API < Sinatra::Base
    register Sinatra::CrossOrigin

    configure do
      enable :cross_origin
    end

    options '*' do
      response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
      200
    end

    before '/stat/*' do
      content_type 'application/json'
      @filter = params.inject({}) { |prms, v|
        if [:from, :til, :by, :in, :color, :labels, :limit,
          :time_stamps].include? v[0].to_sym
          prms[v[0].to_sym] = v[1] 
        end
        prms[v[0].to_sym] = "##{p[v[0].to_sym]}" if v[0] == 'color'
        prms
      }
      @filter[:color] ||= '#97BBCD'
    end

    get '/stat/repo_list' do
      repos = Ginatra::Config.repositories
      repos.map { |key, value|
        { id: key,
          name: value['name'],
          color: value['color'],
          path: value['path'] }
      }.to_json
    end

    get '/stat/hours' do
      Ginatra::Activity.hours(@filter).map { |hours_data|
        { repoId: hours_data[0], hours: hours_data[1] }
      }.to_json
    end

    get '/stat/commits' do
      Ginatra::Stat.commits(@filter).map{ |commit_data|
        commits_arr = commit_data[1].map{ |commit|
          commit.flatten[1]
        }
        { repoId: commit_data[0], commits: commits_arr }
      }.to_json
    end

    get '/stat/commits_overview' do
      Ginatra::Stat.commits_overview(@filter).to_json
    end

    get '/stat/repo_overview' do
      Ginatra::Stat.repo_overview(@filter).map { |overview_data|
        { repoId: overview_data[0], overviewData: overview_data[1] }
      }.to_json
    end

    get '/stat/authors' do
      Ginatra::Stat.authors(@filter).map { |repo|
        { repoId: repo[0], authors: repo[1] }
      }.to_json
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

    get '/test' do
      Ginatra::Helper.get_repo('ginatra').create_commits_data
      [].to_json
    end

    get '/import' do
      Ginatra::Helper.get_repo('ginatra').import_git_graph
      [].to_json
    end

    get '/numstat' do
      Ginatra::Helper.get_repo('ginatra').import_branch_graph
      [].to_json
    end
  end
end
