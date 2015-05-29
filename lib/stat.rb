require 'sinatra/base'
require 'sinatra/config_file'
require_relative 'repository'

module Ginatra
  class Stat < Sinatra::Base
    register Sinatra::ConfigFile

    config_file '../config.yml'

    attr_accessor :repositories

    def initialize
      @repositories = []
      settings.repositories.each do |id, info|
        name = info['name']
        path = info['path']
        @repositories << Repository.new(id, name, path)
      end
      p @repositories
    end
  end
end
