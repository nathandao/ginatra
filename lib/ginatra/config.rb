require 'yaml'
require 'chronic'

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

      def sprint_period
        self.settings['sprint']['period'] * 24 * 60 * 60
      end

      def sprint_reference
        Chronic.parse self.settings['sprint']['reference']
      end

      def sprint_start_date
        today = Chronic.parse 'today at 0:00'
        diff = (today - sprint_reference).abs % sprint_period
        today - diff
      end

      def sprint_end_date
        sprint_start_date + sprint_period - (24 * 60 * 60)
      end
    end
  end
end
