require 'logger'

module Ginatra
  class Log
    attr_accessor :logger
    def initialize
      dirname = Ginatra::Env.data ? Ginatra::Env.data : './logs'
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      @logger = Logger.new(File.expand_path 'ginatra.log', dirname)
    end
  end
end
