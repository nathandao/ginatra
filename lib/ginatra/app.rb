require 'sinatra/base'

require File.expand_path('env', File.dirname(__FILE__))
require File.expand_path('repository', File.dirname(__FILE__))
require File.expand_path('stat', File.dirname(__FILE__))

Encoding.default_external = 'utf-8' if RUBY_VERSION =~ /^1.9/

module Ginatra
  class App < Sinatra::Base

    set :root, Ginatra::Env.root

    get '/' do
      #  ap REPO.commits, :indent => -2
    end

    get '/authors' do
      #  puts REPO.author_stats
    end

    get '/stat' do
      s = Ginatra::Stat.new
      s.commits('git-nathan')
      "HA!"
    end
  end
end
