module Ginatra
  class Helpers
    def parameters(arr)
      arr.inject { |o, n| o.to_s + " " + n.to_s }
    end
  end
end
