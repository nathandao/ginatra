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
        self.settings['sprint']['period'] * 24 * 3600
      end

      def sprint_reference
        Chronic.parse self.settings['sprint']['reference_date']
      end

      def sprint_start_time
        today = Chronic.parse 'today at 0:00'
        diff = 0
        diff = (today - sprint_reference)
        diff = sprint_period + diff if diff < 0
        today - (diff % sprint_period)
      end

      def sprint_end_time
        sprint_start_time + sprint_period
      end

      def sprint_dates
        s = sprint_start_time
        e = sprint_end_time
        date_range = Date.new(s.year, s.month, s.day)..Date.new(e.year, e.month, e.day)
        date_range.map { |d|
          Time.new(d.year, d.month, d.day)
        }.uniq
      end
    end
  end
end
