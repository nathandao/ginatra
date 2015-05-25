require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require_relative 'lib/models'

get '/' do
  repo = Ginatra::Repo.new('path')
  puts repo.authors
  puts repo.commits
end
