require 'yaml'

module Ginatra
  class Config
    class << self

      def settings
        p YAML.load_file(File.expand_path('config.yml', Ginatra::Env.root))
      end

      def repositories
        self.settings['repositories']
      end
    end
  end
end
