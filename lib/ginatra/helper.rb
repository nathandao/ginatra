module Ginatra
  class Helper
    class << self
      def get_repo repo_id
        repo = Ginatra::Config.repositories[repo_id]
        return nil if repo.nil?
        repo['id'] = repo_id
        Ginatra::Repository.new repo
      end

      def sort_commits commits, params
        params[:order] ||= 'desc'
        params[:by] ||= 'date'
        commits = commits.sort_by { |commit|
          commit.flatten[1][params[:by]]
        }
        if params[:order] == 'desc'
          commits.reverse
        else
          commits
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

      def get_repos_with_color
        repos = Ginatra::Config.repositories.keys
        repos.map { |repo|
          { repo => get_repo(repo).color }
        }
      end
    end
  end
end
