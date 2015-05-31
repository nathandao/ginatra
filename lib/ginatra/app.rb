require 'sinatra/base'
require 'awesome_print'
require 'json'

require File.expand_path('env', File.dirname(__FILE__))
require File.expand_path('config', File.dirname(__FILE__))
require File.expand_path('repository', File.dirname(__FILE__))
require File.expand_path('stat', File.dirname(__FILE__))

Encoding.default_external = 'utf-8' if RUBY_VERSION =~ /^1.9/

module Ginatra
  class App < Sinatra::Base

    set :root, Ginatra::Env.root

    get '/' do
      Ginatra::Stat
      #  ap REPO.commits, :indent => -2
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
