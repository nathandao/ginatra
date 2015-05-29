module Ginatra
  class Helpers
    def parameters(arr)
      arr.inject { |o, n| o.to_s + " " + n.to_s }
    end

    def is_repo_path?(path)
      `git -C #{path} status`.index("Your branch").nil? ? true : false
    end
  end
end
