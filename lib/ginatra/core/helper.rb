require 'date'

module Ginatra
  class Helper
    class << self
      def get_repo repo_id
        params = Ginatra::Config.repositories[repo_id]
        return nil if params.nil?
        params['id'] = repo_id
        Ginatra::Repository.new(params)
      end

      def get_repos_with_color
        repos = Ginatra::Config.repositories.keys
        repos.map { |repo|
          { repo => get_repo(repo).color }
        }
      end

      def epoch_time(date_string = '')
        DateTime.parse(date_string).strftime('%s').to_i
      end

      def query_commits(params={})
        repo_ids = repo_ids_from_param_in(params[:in])

        # Get conditions.
        conditions = ["r.id IN #{repo_ids.to_s}"]
        if params[:from]
          from = Ginatra::Helper.epoch_time(params[:from])
          conditions << "c.commit_timestamp >= #{from}"
        end
        if params[:til]
          til = Ginatra::Helper.epoch_time(params[:til])
          conditions << "c.commit_timestamp <= #{til}"
        end
        # Create query parts
        query = ["MATCH (r:Repository)-[:HAS_COMMIT]->(c:Commit)"]
        query << "WHERE #{conditions.join(' AND ')}" if conditions.size > 0
        query << "
WITH c, r.id as repo_id
MATCH (a:Author)-[:AUTHORED]->(c)-[ch:CHANGES]->(:File)
WITH
  repo_id,
  c.hash AS hash,
  c.commit_time AS commit_time,
  c.commit_timestamp AS commit_timestamp,
  c.author_time AS author_time,
  c.message AS message,
  c.parents AS parents,
  ch.additions AS additions,
  ch.deletions AS deletions,
  a.name AS author_name,
  a.email AS author_email
RETURN
  repo_id, hash, commit_time, commit_timestamp, author_time, message,
  additions, deletions, parents, author_name, author_email
ORDER BY #{params[:order_by] ? params[:order_by] : 'commit_timestamp DESC'}
"
        query << "LIMIT #{params[:limit]}" if params[:limit]

        # Send the query.
        session = Ginatra::Db.session
        query_result = session.query(query.join(' '))
        session.close

        # Prepare result with empty commits array for each repo_id
        result = repo_ids.inject({}) { |val, repo_id|
          val[repo_id] ||= []
          val
        }

        # Get formatted result
        query_result.each do |row|
          result[row.repo_id] << {
            hash: row.hash,
            commit_time: row.commit_time,
            commit_timestamp: row.commit_timestamp,
            author_time: row.author_time,
            message: row.message,
            additions: row.additions,
            deletions: row.deletions,
            parents: row.parents,
            author_name: row.author_name,
            author_email: row.author_email
          }
        end

        result.map{ |repo|
          { repo_id: repo[0], commits: repo[1] }
        }
      end

      def query_overview(params = {})
        repo_ids = repo_ids_from_param_in(params[:in])

        # Get conditions.
        conditions = ["r.id IN #{repo_ids.to_s}"]
        if params[:from]
          from = Ginatra::Helper.epoch_time(params[:from])
          conditions << "c.commit_timestamp >= #{from}"
        end
        if params[:til]
          til = Ginatra::Helper.epoch_time(params[:til])
          conditions << "c.commit_timestamp <= #{til}"
        end

        # Create query parts
        query = ["
MATCH
  (r)-[:HAS_COMMIT]->(c:Commit)
WHERE #{conditions.join(' AND')}
WITH c, r
MATCH (a:Author)-[:AUTHORED]->(c)
WITH
  r,
  count(distinct a) as contributor_count,
  count(distinct c) as commit_count
MATCH (:CurrentFileTree {origin_url: r.origin_url})-[:HAS_FILE]->(:File {ignored: 0})<-[ch:CHANGES]-()
RETURN
  r.id as repo_id,
  r.start_timestamp as start_timestamp,
  contributor_count,
  commit_count,
  SUM(ch.additions - ch.deletions) as lines
"]
        # Send the query.
        session = Ginatra::Db.session
        query_result = session.query(query.join(' '))
        session.close

        # Prepare result with empty commits array for each repo_id
        result = repo_ids.inject({}) { |val, repo_id|
          val[repo_id] ||= []
          val
        }

        # Get formatted result
        query_result.each do |row|
          result[row.repo_id] = {
            contributor_count: row.contributor_count,
            commit_count: row.commit_count,
            start_timestamp: row.start_timestamp,
            lines: row.lines
          }
        end
        result
      end

      private

      def repo_ids_from_param_in(param_in)
        repo_ids = []
        # Always use array for :in
        if param_in.nil?
          repo_ids = Ginatra::Config.repositories.keys
        else
          if param_in.class == Array
            repo_ids = param_in
          else
            repo_ids = [param_in]
          end
        end
        repo_ids
      end
    end
  end
end
