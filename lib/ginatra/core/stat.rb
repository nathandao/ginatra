require "chronic"

module Ginatra
  class Stat
    class << self
      def commits(params = {})
        Ginatra::Helper.query_commits(params)
      end

      # def commits(params = {})
      #   if params[:in].nil?
      #     repos = Ginatra::Config.repositories
      #     repos.inject({}) { |output, repo|
      #       repo_id = repo[0]
      #       output[repo_id] = Ginatra::Helper.get_repo(repo_id).commits(params)
      #       output
      #     }
      #   else
      #     { params[:in] => Ginatra::Helper.get_repo(params[:in]).commits(params) }
      #   end
      # end

      def commits_count(params = {})
        commits_count = nil
        if params[:in].nil?
          repos = Ginatra::Config.repositories
          commits_count = repos.inject(0) { |count, repo|
            repo_id = repo[0]
            count += Ginatra::Helper.get_repo(repo_id).commits(params).size
            count
          }
        else
          repo_id = params[:in]
          commits_count = Ginatra::Helper.get_repo(repo_id).commits(params).size
        end
        return commits_count.nil? ? 0 : commits_count
      end

      def repo_overview(params = {})
        repos = params[:in].nil? ? Ginatra::Config.repositories.keys : [params[:in]]
        repos.inject({}) { |result, repo_id|
          result[repo_id] ||= {}
          params[:in] = repo_id
          result[repo_id] = commits_overview params
          result
        }
      end

      def commits_overview(params = {})
        commits_count = 0
        additions = 0
        deletions = 0
        lines = 0
        last_commit = Time.new
        first_commit = Time.new
        last_commit_info = {}
        commits(params).each do |repo_id, repo_commits|
          unless repo_commits.nil?
            commits_count += repo_commits.size
            additions += Ginatra::Helper.get_additions(repo_commits)
            deletions += Ginatra::Helper.get_deletions(repo_commits)
            lines += additions - deletions
            unless repo_commits[0].nil?
              last_commit = repo_commits[0].flatten[1]['date']
              first_commit = repo_commits[-1].flatten[1]['date']
              last_commit_info = repo_commits[0].flatten[1]
            end
          end
        end
        { commits_count: commits_count, additions: additions,
          deletions: deletions, lines: lines,
          last_commit: Chronic.parse(last_commit).to_f * 1000,
          first_commit: Chronic.parse(first_commit).to_f * 1000,
          last_commit_info: last_commit_info }
      end

      def authors(params = {})
        if params[:in].nil?
          result = {}
          Ginatra::Config.repositories.each do |repo|
            repo_id = repo.flatten[0]
            output = { repo_id => [] }
            authors = Ginatra::Helper.get_repo(repo_id).authors params
            authors.each do |author|
              match = output.select { |k, v| k == author['name'] }
              if match.empty?
                output[repo_id] << author
              else
                author.each do |k, v|
                  # TODO: fix this
                end
              end
            end
            result = result.merge(output)
          end
          result
        else
          { params[:in] => Ginatra::Helper.get_repo(params[:in]).authors(params) }
        end
      end

      def lines(params = {})
        if params[:in].nil?
          repos = Ginatra::Config.repositories
          repos.inject({}) { |result, repo|
            repo_id = repo[0]
            result[repo_id] = Ginatra::Helper.get_repo(repo_id).lines params
            result
          }
        else
          Ginatra::Helper.get_repo(params[:in]).lines params
        end
      end

      def list_updated_repos
        updated = ""
        threads = []
        repos = Ginatra::Config.repositories
        repos.each do |key, params|
          if Ginatra::Helper.get_repo(key)
            threads << Thread.new {
              if Ginatra::Helper.get_repo(key).refresh_data == true
                updated += key + ","
              end
            }
          end
        end
        threads.each do |t|
          t.join
        end
        updated[0..-2]
      end

      def start_repo_streams(channel, update_interval)
        threads = []
        repos = Ginatra::Config.repositories
        repos.each do |key, params|
          if Ginatra::Helper.get_repo(key)
            threads << Thread.new {
              Ginatra::Helper.get_repo(key).start_stream(channel, update_interval)
            }
          end
        end
        return threads
      end
    end
  end
end
