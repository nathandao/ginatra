require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'awesome_print'
#require_relative 'lib/helpers'
#require_relative 'lib/path'
require_relative 'lib/repository'
require_relative 'lib/stat'

#REPO = Ginatra::Repo.new('~/Sites/vagrant-nesteoil/git/nesteoil')
REPO = Ginatra::Repository.new('~/ruby-wife/ginatra')

get '/' do
  ap REPO.commits, :indent => -2
end

get '/authors' do
  puts REPO.author_stats
end

get '/stat' do
  stats = Ginatra::Stat.new
  "HOHOHO"
end
