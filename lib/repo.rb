module Ginatra
  class Repository
    attr_accessor :path, :authors, :commits

    def initialize(path)
      @path = path
      @commits = Array.new()
      @authors = Array.new()

      p l_params = parameters(%w{
                              --pretty=full
                              --full-history
                              --shortstat
                            })

      p l_format = parameters(%w{
                            "commit=>%h,
                            author=>%an,
                            date=>%ai<--c-entry-->"
                            })

      l_command = "git -C #{path} log #{l_params} --format=#{l_format}"

      c_logs = `#{l_command}`.split("<--c-entry-->")

      c_logs.each do |c_log|
        c_meta = Hash.new()
        c_log.split("\n").reject { |c| c.empty? }.each do |c_raw|
          if c_raw.index('commit=>') == 0
            c_raw.split(/, /).inject(Hash.new { |h, k|
                                       h[k] = nil }) do |h, s|
              k,v = s.split(/=>/)
              @authors = @authors | [v.to_s] unless k.to_s != "author"
              h[k.to_sym] = v.to_s
              c_meta = [c_meta, h].inject(&:merge)
            end
          else
            # file & line changes
            c_raw.split(/, /).inject(Hash.new { |h, k|
                                       h[k] = nil }) do |h, s|
              k = s.index("+") ? :additions :
                  s.index("-") ? :deletions : :changed
              h[k] = s.match(/[0-9]/).to_s.to_i
              c_meta = [c_meta, h].inject(&:merge)
            end
          end
        end
        @commits << c_meta
      end
    end

    def author_stats
      a_stats = Array.new()
      stats = [:additions, :deletions]
      @commits.group_by { |h| h[:author] }.each do |a_name, c_list|
        c_count = 0
        a_name ||= "N/A"
        a_stats << c_list.inject { |o, n|
          Hash[*stats.map { |k|
                 {:author => a_name,
                  :commits => c_count += 1,
                  k => o[k].to_i + n[k].to_i}
               }.map(&:to_a).flatten]
        }
      end
      a_stats
    end

    private

    def parameters(arr)
      arr.inject { |o, n| o.to_s + " " + n.to_s }
    end
  end
end
