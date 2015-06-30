require_relative '../lib/ginatra'

module GinatraFactory
  def get_all_repos
    Ginatra::Config.repositories.map { |repo_id|
      get_repo(repo_id)
    }
  end

  def get_repo(repo_id = 'repo_1')
    Ginatra::Helper.get_repo(repo_id)
  end
end
