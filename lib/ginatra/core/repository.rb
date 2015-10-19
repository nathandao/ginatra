require 'yajl'
require 'fileutils'
require 'chronic'

module Ginatra
  class Repository
    class MissingName < RuntimeError; end
    class MissingPath < RuntimeError; end
    class InvalidPath < RuntimeError; end
    class MissingId < RuntimeError; end
    class InvalidRepoId < RuntimeError; end

    attr_accessor :id, :path, :name, :commits, :color

    def self.new(params)
      self.validate(params)
      super
    rescue MissingName, MissingPath, MissingId, InvalidPath, InvalidRepoId
      false
    end

    def initialize(params)
      prepare_repo_values(params)
    end

    def authors params = {}
      commits(params).group_by { |commit|
        commit.first[1]['author']
      }.map { |name, commits|
        { 'name' => name,
          'commits' => commits.size,
          'additions' => Ginatra::Helper.get_additions(commits),
          'deletions' => Ginatra::Helper.get_deletions(commits) }
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
          c_line_count -= change['deletions'].to_i
          c_line_count += change['additions'].to_i
        } unless changes.empty?
        line_count
      }
    end

    def refresh_data
      if change_exists?
        remove_data_file
        pull_latest_commits
        get_commits
        return true
      end
      false
    end

    private

    def self.validate(params)
      colors = Ginatra::Config.colors
      repos = Ginatra::Config.repositories
      if params['color'].nil? and !params['id'].nil?
        begin
          params['color'] = colors[repos.find_index { |k,_| k == params["id"] } % colors.size]
        rescue NoMethodError
          raise InvalidRepoId, "#{self.current_path} repository's id is invalid"
        end
      end
      raise MissingName, "repository's name missing" unless params['name']
      raise MissingPath, "repository's path missing" unless params['path']
      raise MissingId, "repository's id missing" unless params['id']
      raise MissingColor, "repository's color missing" unless params['color']
      raise InvalidPath, "repository's path is invalid" unless self.is_repo_path?(params['path'])
    end

    def self.is_repo_path?(path)
      path = File.expand_path(path)
      if path.nil? || !File.directory?(path)
        false
      else
        `git -C "#{path}" status`.match(/On branch/)
      end
    end

    def self.current_path
      'ginatra/repository.rb'
    end

    def prepare_repo_values(params)
      colors = Ginatra::Config.colors
      repos = Ginatra::Config.repositories
      @id = params['id'].strip
      @path = params['path'].strip
      @color = nil
      @name = params['name'].strip
      if params['color'].nil?
        @color = colors[repos.find_index { |k,_| k == @id } % colors.size]
      else
        @color = params['color']
      end
    end

    def data_file
      dirname = Ginatra::Env.data ? Ginatra::Env.data : '../../data'
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path '.' + @id, dirname
    end

    def remove_data_file
      FileUtils.rm(data_file) if File.exists?(data_file)
    end

    def pull_latest_commits
      `git -C #{path} pull &>/dev/null`
    end

    # def track_all_remote_branches
    #   `for i in $(git -C #{@path} branch -r | grep -vE "HEAD|master"); do
    #      git -C #{@path} branch --track ${i#*/} $i;
    #    done >> `
    # end

    def change_exists?
      result = `git -C #{@path} fetch origin
                GINATRA_LOCAL=$(git -C #{@path} rev-parse @)
                GINATRA_REMOTE=$(git -C #{@path} rev-parse @{u})
                if [ $GINATRA_LOCAL = $GINATRA_REMOTE ]; then
                  echo "[ginatra_branch_up_to_date]"
                else
                  echo "[ginatra_branch_refresh_required]"
                fi`
      result.include? "[ginatra_branch_refresh_required]"
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
        file.write(git_log.to_json)
      }
    end

    def git_log since = nil
      c_separator = "[<ginatra_commit_section>]"
      i_separator = "[<ginatra_separator]"
      # path = "~/Sites/emessukeskus"
      str = `git -C #{path} log \
             --numstat \
             --format='#{c_separator}id %h#{i_separator}author %an#{i_separator}date %ai#{i_separator}subject %s#{i_separator}changes'`

      # Create an array of commits, each commit is a string
      commit_section_strs = str.split(c_separator)[1..-1]

      full_commits = []
      commit_section_strs.each do |commit_section_str|
        # Divide each commit string into separate components
        commit_section_arr = commit_section_str.split(i_separator)

        # Get the components based on their order in the array
        commit_hash = {
          id: commit_section_arr[0][3..-1],
          author: commit_section_arr[1][7..-1],
          date: commit_section_arr[2][5..-1],
          subject: commit_section_arr[3][8..-1]
        }

        changes = []
        commit_change_strs = commit_section_arr[4].split("\n")[2..-1]

        unless commit_change_strs.nil?
          commit_change_strs.each do |commit_change_str|
            commit_change = commit_change_str.split("\t")
            changes << {
              addition: commit_change[0],
              deletions: commit_change[1],
              path: commit_change[2]
            }
          end
        end
        # merge changes to commit hash
        commit_hash[:changes] = changes
        full_commits << {commit_hash[:id] => commit_hash}
      end
      return full_commits
    end
  end
end
