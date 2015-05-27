require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require_relative 'lib/helpers'
require_relative 'lib/path'
require_relative 'lib/repo'
require_relative 'lib/stat'

#REPO = Ginatra::Repo.new('~/Sites/vagrant-nesteoil/git/nesteoil')
STATS = Ginatra::RepoStat.new('~/Sites/vagrant-nesteoil/git/nesteoil')

get '/' do
  `git -C ~/Sites/vagrant-nesteoil/git/nesteoil log --author=Rami --shortstat`
end

get '/authors' do
  puts REPO.author_stats
end

get '/stat' do
  STATS
end
