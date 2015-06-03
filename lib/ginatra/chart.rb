module Ginatra
  class Chart
    class << self
      def rc_commits params = {}
        round_chart Ginatra::Stat.commits(params).inject(Hash.new) {
          |result, repo|
          repo_id = repo[0]
          commits = repo[1]
          result[repo_id] = {'value' => commits.size}
          result
        }
      end

      def lc_commits params = {}
        line_chart lc_commits_data params
      end

      def rc_lines params = {}
        round_chart Ginatra::Stat.lines(params).inject(Hash.new) {
          |result, line_data|
          repo_id = line_data[0]
          result[repo_id] = {'value' => line_data[1]}
          result
        }
      end

      def lc_lines params = {}
        line_chart lc_lines_data params
      end

      def lc_combined_lines_commits params = {}
        line_chart lc_combine_data lc_lines_data, lc_commits_data
      end

      private

      def round_chart data = {}
        data.inject([]) { |output, v|
          params = v[1]
          params['label'] = v[0]
          params['highlight'] ||= v[1]['color']
          output << params
          output
        }
      end

      def line_chart data = {}
        c = colors
        init_data = {'labels' => [], 'datasets' => []}
        data.inject(init_data) { |output, v|
          key = v[0]
          if key == 'labels'
            output[key] = v[1]
          else
            output[key] = v[1].inject([]) { |datasets, dataset|
              color = c.pop
              datasets << dataset.merge({'fillColor' => rgba(color, 0.2),
                                         'strokeColor' => rgba(color),
                                         'pointColor' => rgba(color),
                                         'pointStrokeColor' => '#fff',
                                         'pointHighlightFill' => '#fff',
                                         'pointHighlightStroke' => rgba(color)})
              c = colors if c.empty?
              datasets
            }
          end
          output
        }
      end

      def lc_commits_data params = {}
        init_data = {'labels' => [], 'datasets' => [{}]}
        Ginatra::Stat.commits(params).inject(init_data) { |result, repo|
          repo_id = repo[0]
          commits = repo[1]
          result['labels'] << repo_id
          result['datasets'][0]['label'] ||= "Commits"
          result['datasets'][0]['data'] ||= []
          result['datasets'][0]['data'] += [commits.size]
          result
        }
      end

      def lc_lines_data params = {}
        init_data = {'labels' => [], 'datasets' => [{}]}
        Ginatra::Stat.lines(params).inject(init_data) { |result, repo|
          repo_id = repo[0]
          lines_count = repo[1]
          result['labels'] << repo_id
          result['datasets'][0]['label'] ||= "Lines"
          result['datasets'][0]['data'] ||= []
          result['datasets'][0]['data'] << lines_count
          result
        }
      end

      def lc_combine_data data1, data2
        if data1['labels'] == data2['labels']
          return {'labels' => data1['labels'],
                  'datasets' => data1['datasets'] + data2['datasets']
                 }
        else
          return false
        end
      end

      def colors
        ['#114b5f','#028090','#e4fde1','#456990','#f45b69']
      end

      def highlights
        ['#114b5f','#028090','#e4fde1','#456990','#f45b69']
      end

      def rgba hex, a = 1
        hex += hex[1..-1] if hex.length == 4
        hex.match(/#(..)(..)(..)/).to_a[1..-1].inject('rgba(') { |rgba, v|
          rgba += "#{v.hex},"
          rgba
        } + "#{a})"
      end
    end
  end
end
