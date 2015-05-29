module Ginatra
  class RepositoryStat < Repository
    def initialize(path)
      Repository.new(path)
      p @commits.nil? ? "NIL" : "YISS"
    end
  end
end
