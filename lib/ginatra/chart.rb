module Ginatra
  class Chart < Stat
    class << self

      def round_chart_all_commits date_range = []
        round_chart all_commits_between(date_range).inject(Hash.new) { |result, repo|
          repo_id = repo[0]
          commits = repo[1]
          result[repo_id] = {'value' => commits.size}
          result
        }
      end

      def round_chart_all_lines date_range = []
        round_chart all_lines_between(date_range).inject(Hash.new) { |result, line_data|
          repo_id = line_data[0]
          result[repo_id] = {'value' => line_data[1]}
          result
        }
      end

      private

      def round_chart data = Hash.new
        c = colors
        h = highlights
        data.inject([]) { |output, v|
          params = v[1]
          params['label'] = v[0]
          params['color'] ||= c.pop
          params['highlight'] ||= h.pop
          c = colors if c.empty?
          h = highlights if h.empty?
          output << params
          output
        }
      end

      def colors
        ['#114b5f','#028090','#e4fde1','#456990','#f45b69']
      end

      def highlights
        ['#114b5f','#028090','#e4fde1','#456990','#f45b69']
      end

    end

  end
end
