require 'sinatra/base'
require 'sinatra/config_file'

module Ginatra
  class Stat < Sinatra::Base
    register Sinatra::ConfigFile

    config_file '../config.yml'

    attr_accessor :repositories

    def initialize
      @repositories = settings.repositories
    end
end
