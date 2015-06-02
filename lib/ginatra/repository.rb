require 'json'
require 'fileutils'

module Ginatra
  class Repository
    attr_accessor :id, :path, :name, :commits

    def initialize(params)
      @id = params['id']
      @path = params['path']
      @name = params['name']
      @commits = nil
    end

    def commits
      get_commits if @commits.nil?
      return @commits
    end

    def refresh_data
      update_commits
    end

    private

    def data_file
      dirname = File.dirname Ginatra::App.root + '/data/'
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path '.' + @id, dirname
    end

    def get_commits
      update_commits if !File.exists? data_file
      file = File.open data_file
      @commits = JSON.parse file.read
      file.close
    end

    def update_commits
      code = %s{
             if !$F.empty?
               markers = %w{ id author date }
               key = $F[0]
               if key == "changes"
                 puts "\"changes\": ["
               else
                 if markers.include? key
                   $F.shift
                   value = $F.inject { |o, n| o + " " + n }
                   puts key == "id" ? "]\}\},\{\"#{$F[0]}\":\{" : "\"#{key}\": \"#{value}\","
                 else
                   add = $F[0].to_i
                   del = $F[1].to_i
                   file = $F[2].to_s
                   puts "{\"additions\": #{add}, \"deletions\": #{del}, \"path\": \"#{file}\"},"
                 end
               end
             end
               }
      wrapper = %s{ BEGIN{puts "["}; END{puts "]\}\}]"} }
      json_str = `git -C #{@path} log \
                  --numstat --max-count=4 \
                  --format='id %H%nauthor %an%ndate %ai %nchanges' $@ | \
                  ruby -lawne '#{code}' | \
                  ruby -wpe '#{wrapper}' | \
                  tr -d '\n' | \
                  sed "s/,]/]/g; s/]}},//"
      `
      File.open(data_file, 'w') { |file|
        file.write(json_str)
      }
    end
  end
end
