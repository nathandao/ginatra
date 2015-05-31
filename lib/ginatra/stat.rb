
module Ginatra
  class Stat

    class << self

      def commits(repo_id)
        repo_conf = Ginatra::Config.repositories.select { |repo|
          repo['id'] == repo_id
        }.first
        return false if repo_conf.nil?
        id = repo_conf['id']
        name = repo_conf['name']
        path = repo_conf['path']
        Repository.new(id, name, path).commits
      end
    end
  end
end
