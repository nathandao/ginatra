require 'chronic'
require 'csv'
require 'eventmachine'
require 'fileutils'
require 'neo4j-core'
require 'rugged'

module Ginatra
  class Repository
    class MissingName < RuntimeError; end
    class MissingPath < RuntimeError; end
    class InvalidPath < RuntimeError; end
    class MissingId < RuntimeError; end
    class InvalidRepoId < RuntimeError; end

    attr_accessor :id, :path, :name, :commits, :color, :origin_url

    def self.new(params)
      @id ||= params["id"]
      self.validate(params)
      super
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

      if params[:limit]
        params[:limit] = params[:limit].to_i
        result = result[0..params[:limit]-1]
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
      remove_commit_csv_file
      pull_latest_commits
      get_commits
    end

    # def start_stream(channel, update_interval)
    #   EM.add_periodic_timer(update_interval) {
    #     if change_exists?
    #       refresh_data
    #       sid = channel.subscribe { |msg| p ["repo #{@id} subscribed"] }
    #       channel.push @id
    #       channel.unsubscribe(sid)
    #     end

    #     # hit Control + C to stop
    #     Signal.trap("INT")  { EventMachine.stop }
    #     Signal.trap("TERM") { EventMachine.stop }
    #   }
    # end

    def import_branch_graph
      session = Ginatra::Db.session

      # Create constraints
      # TODO: This is only required once during the database setup process.
      session.query('CREATE CONSTRAINT ON (r:Repository) ASSERT r.origin_url IS UNIQUE')

      # Create or update existing repo
      session.query("MERGE (r:Repository {origin_url: '#{@origin_url}', id: '#{@id}', name: '#{@name}'})")

      repo = Rugged::Repository.new(File.expand_path(@path))
      repo.branches.each do |branch|
        # Only add remote branches. Since HEAD is pointed to the current
        # local working branch
        if (branch.target.class == Rugged::Commit && branch.head? == false)
          # Delete previous branch
          session.query("
MATCH (r:Repository {origin_url: '#{@origin_url}'})-[:HAS_BRANCH]->(b:Branch {name: '#{branch.name}'}) DETACH
DELETE b
")

          session.query("
MATCH (r:Repository {origin_url: '#{origin_url}'})
MATCH (c:Commit {hash: '#{branch.target.oid}'})
CREATE (b:Branch {name: '#{branch.name}'})
CREATE (r)-[:HAS_BRANCH]->(b)
MERGE (b)-[:POINTS_TO]->(c)
")
        end
      end
    end

    def create_commits_csv
      repo = Rugged::Repository.new(File.expand_path(@path))
      tips = []

      repo.branches.each do |branch|
        tips << branch.target.oid if (branch.target.class == Rugged::Commit)
      end

      # Create a walker and let the starting points as the latest commit of each
      # branch.
      walker = Rugged::Walker.new(repo)
      tips.uniq.each do |target|
        walker.push(target)
      end

      # Remove the old csv file before writing to the new one
      remove_commit_csv_file

      CSV.open(commit_csv_file, 'w') do |csv|
        # Write CSV headers
        csv << %w{ hash message author_email author_name author_time commit_time commit_timestamp parents }

        # Walk through the commit tree based on the defined start commit points.
        # The walk happens simultatiniously through all branches. Commit that
        # has been processed will be ignored automatically by Rugged::Walker.
        walker.each do |commit|
          author = commit.author
          committor = commit.committer
          csv << [
            commit.oid,
            commit.message.strip().gsub(/\n/, '').gsub(/"/, "'").gsub(/\\/, '\\\\\\'),
            author[:email],
            author[:name],
            author[:time],
            committor[:time],
            commit.time,
            commit.parent_ids.join(' ')
          ]
        end
      end
    end

    def create_diff_csv
      # Using git command to get the line and file changes of each commit
      # since Rugged::Walker takes much longer to walk through the diff stat.

      # Record the line changes output to a string and then reformat it into
      # csv.
      delimiter = '[<ginatra_commit_start>]'
      stat_str = `cd #{path} && git log --numstat --format="#{delimiter}%H"`

      # Split string at delimiter, so each string represents a commit with its
      # commit hash and changes below it.
      stat_arr = stat_str.split(delimiter).map { |str|
        # Each raw_stat string has this format:
        # b3170bb1b7d73062d0807b8acd6474aadfaa83d9
        #
        # 1       3       Gemfile
        # 49      14      Gemfile.lock
        # 0       1       config.ru
        # 0       3       lib/ginatra.rb
        # 33      56      lib/ginatra/core/repository.rb
        # 5       1       lib/ginatra/web/api.rb
        # 0       1       lib/ginatra/web/front.rb
        # 0       1       lib/ginatra/web/websocket_server.rb
        raw_stat = str.split(/\n/)
        commit_hash = raw_stat[0]

        if raw_stat.size <= 2
          changes = []
        else
          changes = raw_stat[3..-1].map{ |change_str|
            raw_change = change_str.split(/\t/)
            {
              file_path: raw_change[2],
              additions: raw_change[0].to_i,
              deletions: raw_change[1].to_i
            }
          }
        end

        { hash: commit_hash, changes: changes }
      }

      # Remove old diff csv file
      remove_diff_csv_file

      CSV.open(diff_csv_file, 'w') do |csv|
        # Write csv headers
        csv << %w{ hash additions deletions file_path }

        # Write rows
        stat_arr.each do |stat|
          stat[:changes].each do |change|
            csv << [
              stat[:hash],
              change[:additions],
              change[:deletions],
              change[:file_path]
            ]
          end
        end
      end
    end


    def import_commits_graph
      create_commits_csv
      session = Ginatra::Db.session

      # Establish contraints in indexes
      # TODO: This is only required once during the database setup process.
      session.query('CREATE CONSTRAINT ON (c:Commit) ASSERT c.hash IS UNIQUE')
      session.query('CREATE INDEX ON :Commit(commit_timestamp)')
      session.query('CREATE INDEX ON :Commit(message)')
      session.query('CREATE CONSTRAINT ON (u:User) ASSERT u.email IS UNIQUE')

      # Import CSV
      session.query("
USING PERIODIC COMMIT 1000
LOAD CSV WITH headers FROM 'file://#{commit_csv_file}' as line

MATCH (r:Repository {id: '#{@id}'})
MERGE (c:Commit {hash: line.hash}) ON CREATE SET
  c.message = line.message,
  c.author_time = line.author_time,
  c.commit_time = line.commit_time,
  c.commit_timestamp = line.commit_timestamp,
  c.parents = split(line.parents, ' ')

MERGE (r)-[:HAS_COMMIT]->(c)

MERGE (u:User:Author {email:line.author_email}) ON CREATE SET u.name = line.author_name
MERGE (u)-[:AUTHORED]->(c)
MERGE (c)-[:AUTHORED_BY]->(u)
MERGE (u)-[:CONTRIBUTED_TO]->(r)

WITH c,line
WHERE line.parents <> ''
FOREACH (parent_hash in split(line.parents, ' ') |
  MERGE (parent:Commit {hash: parent_hash})
  MERGE (c)-[:HAS_PARENT]->(parent))
")
      session.close
    end

    def import_diff_graph
      create_diff_csv
      session = Ginatra::Db.session

      # Establish contraints in indexes
      # TODO: This is only required once during the database setup process.
      session.query('CREATE CONSTRAINT ON (f:File) ASSERT f.path IS UNIQUE')

      # Import CSV
      session.query("
USING PERIODIC COMMIT 1000
LOAD CSV WITH headers FROM 'file://#{diff_csv_file}' as line

MATCH (c:Commit {hash: line.hash})
MERGE (f:File {path: line.file_path})
MERGE (c)-[:CHANGES {additions: line.additions, deletions: line.deletions}]->(f)
")
      session.close
    end

    def import_git_graph
      logger = Ginatra::Log.logger
      logger.info("Started indexing repo #{@id}")

      session = Ginatra::Db.session
      # Create constraints
      session.query('CREATE CONSTRAINT ON (r:Repository) ASSERT r.origin_url IS UNIQUE')
      # Create or update existing repo
      session.query("MERGE (r:Repository {origin_url: '#{@origin_url}', id: '#{@id}', name: '#{@name}'})")
      session.close

      logger.info("Importing commits graph of #{@id}")
      import_commits_graph

      logger.info("Importing branch graph of #{@id}")
      import_branch_graph

      logger.info("Importing commit diff graph of #{@id}")
      import_diff_graph

      logger.info("Finised indexing repository #{id}")
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
      raise MissingName, "repository's name is missing for #{@id}. Check config.yml file, make sure your data is correct." unless params['name']
      raise MissingPath, "repository's path is missing for #{@id}. Check config.yml file, make sure your data is correct." unless params['path']
      raise MissingId, "repository's id is missing. Check config.yml file, make sure your repository data is correct." unless params['id']
      raise MissingColor, "repository's color missing for #{@id}. Check config.yml file, make sure your data is correct." unless params['color']
      raise InvalidPath, "repository's path is invalid for #{@id}. Check config.yml file, make sure your data is correct." unless self.is_repo_path?(params['path'])
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

      # Get default color if it is not defined
      if params['color'].nil?
        @color = colors[repos.find_index { |k,_| k == @id } % colors.size]
      else
        @color = params['color']
      end

      # Find remote url
      repo = Rugged::Repository.new(File.expand_path(@path))
      @origin_url = nil
      repo.remotes.each do |remote|
        @origin_url = remote.url if remote.name == 'origin'
      end
    end

    def commit_csv_file
      dirname = Ginatra::Env.data ? Ginatra::Env.data : './data'
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path @id + '.csv', dirname
    end

    def diff_csv_file
      dirname = Ginatra::Env.data ? Ginatra::Env.data : './data'
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path @id + '_diff.csv', dirname
    end

    def remove_commit_csv_file
      FileUtils.rm(commit_csv_file) if File.exists?(commit_csv_file)
    end

    def remove_diff_csv_file
      FileUtils.rm(diff_csv_file) if File.exists?(diff_csv_file)
    end

    def pull_latest_commits
      `git -C #{path} pull --rebase &>/dev/null`
    end

    # def track_all_remote_branches
    #   `for i in $(git -C #{@path} branch -r | grep -vE "HEAD|master"); do
    #      git -C #{@path} branch --track ${i#*/} $i;
    #    done >> `
    # end

    def change_exists?
      result = `git -C #{@path} fetch origin &>/dev/null
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
      unless commits.nil?
        commits.each do |commit|
          commit_date = Time.parse commit.flatten[1]['date']
          break if commit_date < date_range[0]
          result << commit if commit_date >= date_range[0] &&
            commit_date <= date_range[1]
        end
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

    # def get_commits
    #   create_commits_data unless File.exists?(commit_csv_file)
    # end

#     def git_log
#       dirname = Ginatra::Env..data ? Ginatra::Env.data : './data'
#       FileUtils.mkdir_p dirname unless File.directory?(dirname)
#       csv_file_path = File.expand_path @id + '.csv', dirname
#       d = '<ginatra_delimiter>'
#       `cd #{path} && \
# echo "sha1,hash,parents,author_email,author_name,refs,subject,timestamp,date_time" > #{csv_file_path} && \
# git log --reverse --no-merges --format='%H#{d}%h#{d}%P#{d}%ae#{d}%an#{d}%d#{d}%s#{d}%at#{d}%ai' | \
# sed '/^$/d' | \
# sed 's/\n/-/g' | \
# sed 's/,/;/g' | \
# sed 's/#{d}/,/g >> #{csv_file_path} && \
# git log --reverse --no-merges --pretty=tformat: 
# `
#       `cd #{path} && \
# echo "sha1#{bash_tab}hash#{bash_tab}parents#{bash_tab}author_email#{bash_tab}author_name#{bash_tab}refs#{bash_tab}subject#{bash_tab}timestamp#{bash_tab}date_time#{bash_tab}changes" > #{csv_file_path} && \
# IFS=$'\n'
# DATA=(\`git log --reverse --format='"%H","%h","%P","%ae","%an","%d","%f","%at","%ai",'\`)
# LINES=(\`git log --pretty=format: --shortstat\`)
# i=0
# while [ $i -lt ${#DATA[@]} ]; do
#     echo ${DATA[$i]}\"${LINES[$i]}\"
#     i=$[i + 1]
# done >> #{csv_file_path}
#       `
#   end
  end
end
