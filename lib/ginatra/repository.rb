require 'json'
require 'fileutils'
require 'chronic'

module Ginatra
  class Repository
    attr_accessor :id, :path, :name, :commits, :color

    def initialize params
      @id = params['id']
      @path = params['path']
      @name = params['name']
      @color = params['color'].nil? ? nil : params['color']
      @commits = nil
    end

    def commits
      get_commits if @commits.nil?
      @commits
    end

    def commits_between date_range = []
      if date_range.empty?
        commits
      else
        date_range = date_range.map { |time_stamp|
          Chronic.parse time_stamp if time_stamp.class != 'Time'
        }
        date_range << Time.now if date_range.size == 1
        commits.select { |commit|
          commit_date = Chronic.parse commit.flatten[1]['date']
          date_range[0] <= commit_date && date_range[1] >= commit_date
        }
      end
    end

    def commits_by_author name = nil
      if name.nil?
        return commits
      else
        return commits.select { |commit|
          commit.flatten[1]['author'] == name
        }
      end
    end

    def refresh_data
      `git -C #{@path} pull >> /dev/null 2>&1`
      if JSON.parse(git_log(1))[0] != commits[0]
        count = 1
        loop do
          if JSON.parse(git_log(count)).last == commits[0]
            File.open(data_file, 'w') { |file|
              file.write (JSON.parse(git_log(count - 1)) + commits).to_json
            }
            break
          end
          count += 1
        end
      end
    end

    private

    def data_file
      dirname = Ginatra::App.data
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path '.' + @id, dirname
    end

    def get_commits
      create_commits_data unless File.exists?(data_file)
      file = File.open data_file
      @commits = JSON.parse(file.read)
      file.close
    end

    def create_commits_data
      File.open(data_file, 'w') { |file|
        file.write(git_log)
      }
    end

    def git_log max_count = 0
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
      maxcount = max_count > 0 ? "--max-count=#{max_count}" : ''
      json_str = `git -C #{@path} log \
       --numstat #{maxcount} \
       --format='id %H%nauthor %an%ndate %ai %nchanges' $@ | \
       ruby -lawne '#{code}' | \
       ruby -wpe '#{wrapper}' | \
       tr -d '\n' | \
       sed "s/,]/]/g; s/]}},//"
      `
      return json_str
    end

  end
end
