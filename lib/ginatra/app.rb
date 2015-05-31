require 'sinatra/base'
require 'awesome_print'

require File.expand_path('env', File.dirname(__FILE__))
require File.expand_path('config', File.dirname(__FILE__))
require File.expand_path('repository', File.dirname(__FILE__))
require File.expand_path('stat', File.dirname(__FILE__))

Encoding.default_external = 'utf-8' if RUBY_VERSION =~ /^1.9/

module Ginatra
  class App < Sinatra::Base

    set :root, Ginatra::Env.root

    get '/' do
      Ginatra::Config.settings
      #  ap REPO.commits, :indent => -2
    end

    get '/authors' do
      #  puts REPO.author_stats
    end

    get '/stat' do
      ap Ginatra::Stat.commits('ginatra')
      "HA!"
    end
  end
end
