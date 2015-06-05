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
    end
  end
end
