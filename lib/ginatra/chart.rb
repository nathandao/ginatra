require 'chronic'

module Ginatra
  class Chart
    class << self
      def rc_commits params = {}
        round_chart Ginatra::Stat.commits(params).inject({}) { |result, repo|
          repo_id = repo[0]
          commits = repo[1]
          result[repo_id] = {'value' => commits.size}
          result
        }
      end

      def rc_lines params = {}
        round_chart Ginatra::Stat.lines(params).inject({}) { |result, line_data|
          repo_id = line_data[0]
          result[repo_id] = {'value' => line_data[1]}
          result
        }
      end

      def rc_hours params = {}
        Ginatra::Activity.hours(params).inject({}) { |output, hour|
          repo_id = hour[0]
          output.merge!({repo_id => total_hours(repo[1])})
          output
        }
      end

      def lc_commits params = {}
        line_chart lc_data params, 'commits'
      end

      def lc_lines params = {}
        line_chart lc_data params, 'lines'
      end

      def lc_hours params = {}
        line_chart lc_data params, 'hours'
      end

      def lc_combined_lines_commits params = {}
        line_chart lc_combine_data lc_lines_data(params), lc_commits_data(params)
      end

      def timeline_commits params = {}
        # default to 1 week from now
        params[:time_stamps] ||= default_timeline_stamps
        time_stamp_str = params[:time_stamps]
        time_stamps = time_stamp_str.map { |time_stamp|
          Chronic.parse time_stamp
        }
        params.reject! { |k| k == :time_stamps }
        init_data = {'labels' => [], 'datasets' => [{'label' => 'Commits', 'data' => []}]}
        count = 0
        line_chart time_stamps[0..-2].inject(init_data) { |output, time_stamp|
          params[:from] = time_stamp
          params[:til] = time_stamps[count+1] - 1
          commits_count = Ginatra::Stat.commits_count params
          output['datasets'][0]['data'] << commits_count
          count += 1
          output
        }.merge({'labels' => time_stamp_str[0..-2]})
      end

      private

      def get_repo_color repo_id
        Ginatra::Helper.get_repo(repo_id).color
      end

      def round_chart data = {}
        data.inject([]) { |output, v|
          repo_id = v[0]
          color = get_repo_color repo_id
          params = v[1]
          params['label'] = v[0]
          params['highlight'] ||= color
          params['color'] ||= color
          output << params
          output
        }
      end

      def line_chart data = {}
        data['datasets'].each_with_index do |dataset, i|
          color = dataset['color'].nil? ? '#97BBCD' : dataset['color']
          data['datasets'][i].merge! ({
                                       'fillColor' => rgba(color, 0.2),
                                       'strokeColor' => rgba(color),
                                       'pointColor' => rgba(color),
                                       'pointStrokeColor' => '#ffffff',
                                       'pointHighlightFill' => '#ffffff',
                                       'pointHighlightStroke' => rgba(color)
                                      })
        end
        data
      end

      def lc_data params = {}, data_type = 'commits'
        case data_type
        when 'commits'
          lc_commits_data params
        when 'lines'
          lc_lines_data params
        else
          # type = 'hours'
          lc_hours_data params
        end
      end

      def lc_commits_data params = {}
        init_data = {'labels' => [], 'datasets' => [{}]}
        Ginatra::Stat.commits(params).inject(init_data) { |result, repo|
          repo_id = repo[0]
          commits = repo[1]
          result['labels'] << repo_id
          result['datasets'][0]['label'] ||= "Commits"
          result['datasets'][0]['data'] ||= []
          result['datasets'][0]['data'] << commits.size
          result['datasets'][0]['color'] = params[:color]
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
          result['datasets'][0]['color'] = params[:color]
          result
        }
      end

      def lc_hours_data params = {}
        init_data = {'labels' => [], 'datasets' => [{}]}
        Ginatra::Activity.hours(params).inject(init_data) { |result, repo|
          repo_id = repo[0]
          result['labels'] << repo_id
          result['datasets'][0]['label'] ||= "Hours"
          result['datasets'][0]['data'] ||= []
          result['datasets'][0]['data'] << total_hours(repo[1])
          result['datasets'][0]['color'] = params[:color]
          result
        }
      end

      def lc_combine_data data1, data2
        if data1['labels'] == data2['labels']
          {'labels' => data1['labels'],
              'datasets' => data1['datasets'] + data2['datasets']}
        else
          false
        end
      end

      def default_timeline_stamps
        ['7 days ago at 0:00', '6 days ago at 0:00', '5 days ago at 0:00',
         '4 days ago at 0:00', '3 days ago at 0:00', 'yesterday at 0:00', '0:00', 'now']
      end

      def total_hours hours_data = {}
        hours_data.inject(0.00) { |total, author|
          total += author['hours']
          total
        }
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
