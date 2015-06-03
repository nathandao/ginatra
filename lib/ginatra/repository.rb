require 'yajl'
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

    def authors
      commits.group_by { |commit|
        commit.first[1]['author']
      }.map { |name, commits|
        {
         'name' => name,
         'commits' => commits.size,
         'additions' => get_additions(commits),
         'deletions' => get_deletions(commits)
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
        result = commits_between '1/1/1', params[:til]
      else
        result = @commits
      end
      commits_by result, params[:by]
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
      if @commits.nil?
        get_commits
      else
        last_commit_date = commits[0].flatten[1]['date']
        new_commits = Yajl::Parser.new.parse(git_log(last_commit_date))
        Yajl::Encoder.encode(new_commits + commits, File.new(data_file, 'w')) unless new_commits.empty?
      end
    end

    private

    def data_file
      dirname = Ginatra::App.data
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path '.' + @id, dirname
    end

    def commits_between from = 0, til = Time.now
      date_range = [from, til].map { |time_stamp|
        Chronic.parse(time_stamp.to_s)
      }
      result = []
      commits.each do |commit|
        commit_date = Chronic.parse(commit.flatten[1]['date'])
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

    def get_additions commits
      get_commit_value commits, 'additions'
    end

    def get_deletions commits
      get_commit_value commits, 'deletions'
    end

    def get_commit_value commits, key
      value = 0
      commits.each do |commit|
        commit.each do |k, v|
          v['changes'].each do |change|
            value += change[key] unless change[key].nil?
          end
        end
      end
      value
    end

    def get_commits
      create_commits_data unless File.exists?(data_file)
      file = File.new data_file, 'r'
      parser = Yajl::Parser.new
      @commits = parser.parse file
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
      since = since.nil? ? '' : "--since=#{since}"
      json_str = `git -C #{@path} log \
       --numstat #{since} \
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
