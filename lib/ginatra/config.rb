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

      def colors
        self.settings['colors']
      end

      def threshold
        self.settings['threshold']
      end
    end
  end
end
