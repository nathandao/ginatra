module Ginatra
  class Stat
    class << self
      def commits params = {}
        if params[:in].nil?
          repos = Ginatra::Config.repositories
          repos.inject({}) { |output, repo|
            repo_id = repo[0]
            output[repo_id] = Ginatra::Helper.get_repo(repo_id).commits params
            output
          }
        else
          { params[:in] => Ginatra::Helper.get_repo(params[:in]).commits(params) }
        end
      end

      def authors params = {}
        if params[:in].nil?
          Ginatra::Config.repositories.inject([]) { |output, repo|
            repo_id = repo[0]
            authors = Ginatra::Helper.get_repo(repo_id).authors params
            authors.each do |author|
              match = output.select { |k, v| k == author['name'] }
              if match.empty?
                output << author
              else
                author.each do |k, v|
                  # TODO: fix this
                end
              end
            end
          }
        else
          Ginatra::Helper.get_repo(params[:in]).authors params
        end
      end

      def lines params = {}
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

      def refresh_all_data
        repos = Ginatra::Config.repositories
        repos.each do |key, params|
          Ginatra::Helper.get_repo(key).refresh_data
        end
      end
    end
  end
end
