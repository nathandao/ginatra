require 'yaml'

module Ginatra
  class Config
    class << self
      def settings
        YAML.load_file File.expand_path 'config.yml', Ginatra::App.root
      end

      def repositories
        self.settings['repositories']
      end
    end
  end
end
