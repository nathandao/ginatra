module Ginatra
  class Stat

    class << self
      def commits(repo_id)
        repo = Ginatra::Config.repositories[repo_id]
        return false if repo.nil?
        repo['id'] = repo_id
        Ginatra::Repository.new(repo).commits
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

    end
  end
end
