module Ginatra
  class RepoStat < Repo
    def initialize(path)
      Repo.new(path)
      p @commits.nil? ? "NIL" : "YISS"
    end
  end
end
