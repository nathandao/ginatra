require 'yajl'
require 'fileutils'
require 'chronic'

module Ginatra
  class Repository
    include Redis::Objects

    attr_accessor :id, :path, :name, :commits, :color

    def initialize params
      colors = Ginatra::Config.colors
      repos = Ginatra::Config.repositories
      @id = params['id']
      @path = params['path']
      @color = nil
      @name = params['name']
      if params['color'].nil?
        @color = colors[repos.find_index { |k,_| k == @id } % colors.size]
      else
        @color = params['color']
      end
    end

    def authors params = {}
      commits(params).group_by { |commit|
        commit.first[1]['author']
      }.map { |name, commits|
        {
         'name' => name,
         'commits' => commits.size,
         'additions' => Ginatra::Helper.get_additions(commits),
         'deletions' => Ginatra::Helper.get_deletions(commits)
        }
      }
    end

    def commits params = {}
      # initiate @commits if not set
      get_commits if @commits.nil?
      result = nil
      if params[:from] && params[:til]
        result = commits_between params[:from], params[:til]
      elsif params[:from]
        result = commits_between params[:from], Time.now
      elsif params[:til]
        result = commits_between Time.new(0), params[:til]
      else
        result = @commits
      end
      commits_by(result, params[:by])
    end

    def lines params = {}
      commits(params).inject(0) { |line_count, commit|
        changes = commit.flatten[1]["changes"]
        line_count += changes.inject(0) { |c_line_count, change|
          c_line_count -= change['deletions']
          c_line_count += change['additions']
        } unless changes.empty?
        line_count
      }
    end

    def refresh_data
      `git -C #{@path} pull >> /dev/null 2>&1`
      if commits.nil?
        get_commits
      else
        last_commit_date = Time.parse commits[0].flatten[1]['date']
        last_commit_id = commits[0].keys[0]
        new_commits = Yajl::Parser.new.parse(git_log(last_commit_date))
        unless new_commits.empty?
          new_commits.reject! { |c| c.keys[0] == last_commit_id }
          Yajl::Encoder.encode(new_commits + commits, File.new(data_file, 'w')) unless new_commits.empty?
        end
      end
    end

    private

    def data_file
      dirname = Ginatra::App.data
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path '.' + @id, dirname
    end

    def commits_between from = nil, til = nil
      from ||= Time.new(0)
      til ||= Time.now
      date_range = [from, til].map { |time_stamp|
        if time_stamp.class.to_s != "Time"
          Chronic.parse time_stamp.to_s
        else
          time_stamp
        end
      }
      result = []
      commits.each do |commit|
        commit_date = Time.parse commit.flatten[1]['date']
        break if commit_date < date_range[0]
        result << commit if commit_date >= date_range[0] &&
          commit_date <= date_range[1]
      end
      return result
    end

    def commits_by comm = @commits, author = nil
      if author.nil?
        comm
      else
        comm.select { |commit|
          commit.flatten[1]['author'] == author
        }
      end
    end

    def get_commits
      create_commits_data unless File.exists?(data_file)
      file = File.new data_file, 'r'
      parser = Yajl::Parser.new
      @commits = parser.parse file
      @commits
    end

    def create_commits_data
      File.open(data_file, 'w') { |file|
        file.write(git_log)
      }
    end

    def git_log since = nil
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
      since = since.nil? ? '' : "--since='#{since.to_s}'"
      `git -C #{@path} log \
       --numstat #{since} \
       --format='id %h%nauthor %an%ndate %ai %nchanges' $@ | \
       ruby -lawne '#{code}' | \
       ruby -wpe '#{wrapper}' | \
       tr -d '\n' | \
       sed "s/,]/]/g; s/]}},//"
      `
    end
  end
end
