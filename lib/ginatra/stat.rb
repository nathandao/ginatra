require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require_relative 'repository'


module Ginatra
  class Stat
    attr_accessor :repositories

    def initialize
      @repositories = []
      REPOS.each do |id, info|
        p info
        name = info['name']
        path = info['path']
        @repositories << Repository.new(id, name, path)
      end
    end

    def commits(repo_id)
      select = @repositories.select{ |repo|
        repo.id == repo_id
      }
      select.empty? ? false : select.first
    end
  end
end
