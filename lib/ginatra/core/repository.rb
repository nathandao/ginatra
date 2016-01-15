require 'chronic'
require 'csv'
require 'eventmachine'
require 'fileutils'
require 'neo4j-core'
require 'rugged'
require 'date'

module Ginatra
  class Repository
    class MissingName < RuntimeError; end
    class MissingPath < RuntimeError; end
    class InvalidPath < RuntimeError; end
    class MissingId < RuntimeError; end
    class InvalidRepoId < RuntimeError; end

    attr_accessor :id, :path, :name, :color, :origin_url, :rugged_repo, :head_branch

    def self.new(params)
      @id ||= params["id"]
      self.validate(params)
      super
    end

    def initialize(params)
      colors = Ginatra::Config.colors
      repos = Ginatra::Config.repositories
      @id = params['id'].strip
      @path = File.expand_path params['path'].strip
      @color = nil
      @name = params['name'].strip
      @rugged_repo = Rugged::Repository.new(File.expand_path(@path))
      @head_branch = @rugged_repo.head.name.sub(/^refs\/heads\//, '')

      # Get default color if it is not defined
      if params['color'].nil?
        @color = colors[repos.find_index { |k,_| k == @id } % colors.size]
      else
        @color = params['color']
      end

      # Find remote url
      @origin_url = nil
      @rugged_repo.remotes.each do |remote|
        @origin_url = remote.url if remote.name == 'origin'
      end
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

    def commits(params = {})
      params[:in] = [@id]
      Ginatra::Helper.query_commits(params).first[:commits]
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

    # def fetch
    #   # cred = Rugged::Credentials::SshKey.new({ username: 'git', publickey: 'id_rsa.pub', privatekey: 'id_rsa', passphrase: '' })
    #   @rugged_repo.remotes.each do |remote|
    #     remote.fetch({ credentials: @credentials })
    #   end
    # end

    def pull
      # Pull rebase on all remote branches
      @rugged_repo.branches.each do |branch|
        if (branch.target.class == Rugged::Commit && branch.head? == false)
          branch_name = branch.name.split('/')[1..-1].join('/')
          `cd #{@path} && git checkout #{branch_name}`
          `cd #{@path} && git pull --rebase`
        end
      end

      # Checkout to default head branch again
      `cd #{path} && git checkout #{@head_branch}`
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

      @rugged_repo.branches.each do |branch|
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
      tips = []
      @rugged_repo.branches.each do |branch|
        tips << branch.target.oid if (branch.target.class == Rugged::Commit)
      end

      # Create a walker and let the starting points as the latest commit of each
      # branch.
      walker = Rugged::Walker.new(@rugged_repo)
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
            commit.epoch_time,
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
              file_path_on_disk: [@path, raw_change[2]].join('/'),
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
        csv << %w{ hash additions deletions file_path file_path_on_disk }

        # Write rows
        stat_arr.each do |stat|
          stat[:changes].each do |change|
            csv << [
              stat[:hash],
              change[:additions],
              change[:deletions],
              change[:file_path],
              change[:file_path_on_disk],
            ]
          end
        end
      end
    end

    def set_repo_graph_start_time
      session = Ginatra::Db.session
      session.query("
MATCH (r:Repository {origin_url: '#{@origin_url}'})-[:HAS_COMMIT]->(c:Commit)
WITH r, c ORDER BY c.commit_timestamp LIMIT 1
SET r.start_timestamp = c.commit_timestamp
")
      session.close
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
  c.commit_timestamp = toInt(line.commit_timestamp),
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

      # Set repo's start timestamp property based on first commit's timestamp
      set_repo_graph_start_time
    end

    def import_diff_graph
      create_diff_csv
      session = Ginatra::Db.session

      # Establish contraints in indexes
      # TODO: This is only required once during the database setup process.
      session.query('CREATE CONSTRAINT ON (f:File) ASSERT f.path_on_disk IS UNIQUE')

      # Import CSV
      session.query("
USING PERIODIC COMMIT 1000
LOAD CSV WITH headers FROM 'file://#{diff_csv_file}' as line

MATCH (c:Commit {hash: line.hash})
MERGE (f:File {path_on_disk: line.file_path_on_disk}) ON CREATE SET
  f.path = line.file_path,
  f.ignored = 0
MERGE (c)-[:CHANGES {additions: toInt(line.additions), deletions: toInt(line.deletions)}]->(f)
")
      session.close
    end

    def create_current_files_csv
      files_tree = Dir["#{@path}/**/*"].reject{ |path| path == "#{@path}/.git" }.map{ |path|
        file_parts = path.split('/')
        {
          relative_path: file_parts[@path.split('/').size..-1].join('/'),
          disk_path: path
        }
      }

      # Remove old files csv file
      remove_current_files_csv_file

      CSV.open(current_files_csv_file, 'w') do |csv|
        # Write csv headers
        csv << %w{ file_path file_path_on_disk ignored }

        # Write rows
        files_tree.each do |file|
          csv << [
            file[:relative_path],
            file[:disk_path],
            @rugged_repo.path_ignored?("#{file[:relative_path]}") ? 1 : 0
          ]
        end
      end
    end

    def import_current_files_graph
      create_current_files_csv
      session = Ginatra::Db.session

      # Establish contraints in indexes
      # TODO: This is only required once during the database setup process.
      session.query('CREATE CONSTRAINT ON (tr: CurrentFileTree) ASSERT tr.origin_url IS UNIQUE')

      # Create the repo's file tree node if it has not existed
      session.query("
MATCH (r:Repository {origin_url: '#{@origin_url}'})
WITH r
MERGE (r)-[:HAS_FILE_TREE]->(:CurrentFileTree {origin_url: '#{@origin_url}'})
")

      # Remove all currently files relationship from the file tree in order
      # to construct the new one based on the current directory
      session.query("
MATCH (:CurrentFileTree {origin_url: '#{@origin_url}'})-[r:HAS_FILE]->(:File)
DELETE r
")

      # Import CSV
      session.query("
USING PERIODIC COMMIT 1000
LOAD CSV WITH headers FROM 'file://#{current_files_csv_file}' as line

MATCH
  (f:File {path_on_disk: line.file_path_on_disk}),
  (tr:CurrentFileTree {origin_url: '#{@origin_url}'})
MERGE (tr)-[:HAS_FILE]->(f)
SET f.ignored = toInt(line.ignored)
")

      session.close
    end

    def import_git_graph
      logger = Ginatra::Log.new().logger
      logger.info("Started indexing repo #{@id}")
      start_time = Time.now

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

      logger.info("Importing current files graph of #{@id}")
      import_current_files_graph

      logger.info("Setting start timestamp of #{@id}")
      set_repo_graph_start_time

      logger.info("Finished indexing repository #{id}. Duration: #{Time.now - start_time} seconds")
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

    def commit_csv_file
      dirname = Ginatra::Env.data ? Ginatra::Env.data : './data'
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path @id + '.csv', dirname
    end

    def remove_commit_csv_file
      FileUtils.rm(commit_csv_file) if File.exists?(commit_csv_file)
    end

    def diff_csv_file
      dirname = Ginatra::Env.data ? Ginatra::Env.data : './data'
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path @id + '_diff.csv', dirname
    end

    def remove_diff_csv_file
      FileUtils.rm(diff_csv_file) if File.exists?(diff_csv_file)
    end

    def current_files_csv_file
      dirname = Ginatra::Env.data ? Ginatra::Env.data : './data'
      FileUtils.mkdir_p dirname unless File.directory?(dirname)
      File.expand_path @id + '_current_files.csv', dirname
    end

    def remove_current_files_csv_file
      FileUtils.rm(current_files_csv_file) if File.exists?(current_files_csv_file)
    end

    def pull_latest_commits
      `git -C #{path} pull --rebase &>/dev/null`
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
  end
end
