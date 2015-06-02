module Ginatra
  class Chart < Stat
    class << self

      def polararea_all_commits date_range = []
        polararea all_commits_between(date_range).inject(Hash.new) { |o, n|
          id = n[0]
          c = n[1]
          o[id] = {'value' => c.size}
          o
        }
      end

      private

      def polararea data = Hash.new
        c = colors
        h = highlights
        data.inject([]) { |output, v|
          params = v[1]
          params['label'] = v[0]
          params['color'] ||= c.pop
          params['highlight'] ||= h.pop
          c = colors if c.empty?
          h = highlights if h.empty?
          output << params
          output
        }
      end

      def colors
        ['#114b5f','#028090','#e4fde1','#456990','#f45b69']
      end

      def highlights
        ['#114b5f','#028090','#e4fde1','#456990','#f45b69']
      end

    end

  end
end
