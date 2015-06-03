module Ginatra
  class Stat
    class << self
      def commits params = {}
        if params[:in].nil?
          repos = Ginatra::Config.repositories
          repos.inject({}) { |output, repo|
            repo_id = repo[0]
            output[repo_id] = get_repo(repo_id).commits params
            output
          }
        else
          get_repo(params[:in]).commits params
        end
      end

      def authors params = {}
        if params[:in].nil?
          # TODO: list authors stats from all commits
        else
          get_repo(params[:in]).authors
        end
      end

      def lines params = {}
        if params[:in].nil?
          repos = Ginatra::Config.repositories
          repos.inject(0) { |total, repo|
            repo_id = repo[0]
            total += get_repo(repo_id).lines params
            total
          }
        else
          get_repo(params[:in]).lines params
        end
      end

      def refresh_all_data
        repos = Ginatra::Config.repositories
        repos.each do |key, params|
          get_repo(params).refresh_data
        end
      end

      private

      def get_repo repo_id
        repo = Ginatra::Config.repositories[repo_id]
        return nil if repo.nil?
        repo['id'] = repo_id
        Ginatra::Repository.new repo
      end
    end
  end
end
