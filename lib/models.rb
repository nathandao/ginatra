module Ginatra
  class Repo
    attr_accessor :path, :authors, :commits

    class << self
    end


    def initialize(path)
      @path = path
      @commits = Array.new()
      @authors = Array.new()

      r_path = "~/Sites/vagrant-nesteoil/git/nesteoil"
      l_params = "--pretty=full --full-history --shortstat"
      l_format = '"commit=>%h, author=>%an, date=>%ai<--c-entry-->"'
      l_command = "git -C #{r_path} log #{l_params} --format=#{l_format}"

      c_logs = `#{l_command}`.split("<--c-entry-->")

      c_logs.each do |c_log|
        c_meta = Hash.new()

        c_log.split("\n").reject { |c|
          c.empty? }.each do |c_raw|
          if c_raw.index('commit=>') == 0
            c_raw.split(/, /).inject(Hash.new{ |h, k| h[k] = nil }) do |h, s|
              k,v = s.split(/=>/)
              @authors = @authors | [v] unless k.to_s != "author"
              h[k.to_sym] = v
              c_meta = [c_meta, h].inject(&:merge)
            end
          else
            # file & line changes
            c_raw.split(/, /).map{ |s|
              s.match(/[0-9]/).to_s.to_i }
          end
        end
        @commits << c_meta
      end
    end
  end
end
