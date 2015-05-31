module Ginatra
  class Helper
    def is_repository?(path)
      `git -C #{path} status`.index("Your branch").nil? ? false : true
    end
  end
end
