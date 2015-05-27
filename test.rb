commits = [
           {:name => "nathan dao", :a => 12, :b => 12, :c => 12},
           {:name => "nathan dao", :a => 12, :c => 12},
           {:name => "nathan dao", :a => 12, :b => 12, :c => 12},
           {:name => "rami", :a => 12, :c => 12},
           {:name => "rami", :a => 12, :b => 12, :c => 12},
           {:name => "rami", :a => 12, :b => 12, :c => 12},
           {:name => "rami", :a => 12, :c => 12},
           {:name => "rami", :a => 12, :b => 12, :c => 12},
           {:name => "rami", :a => 12, :b => 12, :c => 12},
           {:name => "matti", :a => 12, :b => 12, :c => 12,},
           {:name => "nathan dao", :a => 12, :b => 12, :c => 12,},
           {:name => "matti", :a => 12, :b => 12, :c => 12}
          ]
stats = [:a, :b, :c]

commits.group_by{ |h| h[:name] }.each do |k, v|
  v.inject { |h, o|
    Hash[*stats.map { |m|
           {:author => k, m => h[m].to_i + o[m].to_i}
         }.map(&:to_a).flatten]
  }
end
