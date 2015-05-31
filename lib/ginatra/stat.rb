module Ginatra
  class Stat

    class << self
      def commits(repo_id)
        get_repo(repo_id).commits
      end

      def all_commits
        commits = []
        repos = Ginatra::Config.repositories
        repos.each do |id, repo|
          repo['id'] = id
          commits << Ginatra::Repository.new(repo).commits
        end
        commits
      end

      def authors(repo_id)
        get_repo(repo_id).commits.group_by { |commit|
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

      def lines(repo_id)
        lines = 0
        commits = get_repo(repo_id).commits
        commits.each do |commit|
          commit.each do |id, info|
            info["changes"].each do |change|
              lines += line_change change
            end
          end
        end
        lines
      end

      private

      def get_repo(repo_id)
        repo = Ginatra::Config.repositories[repo_id]
        return nil if repo.nil?
        repo['id'] = repo_id
        Ginatra::Repository.new(repo)
      end

      def get_commit_value(commits, key)
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

      def get_additions(commits)
        get_commit_value(commits, 'additions')
      end

      def get_deletions(commits)
        get_commit_value(commits, 'deletions')
      end

    end
  end
end
