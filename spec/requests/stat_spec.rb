require_relative '../spec_helper.rb'

describe Ginatra::Stat do
  describe "commits" do
    before(:each) do
      @stat = Ginatra::Stat
      @repo_1 = get_repo('repo_1')
      @repo_2 = get_repo('repo_2')
    end

    context "without custom params" do
      let(:commits) { @stat.commits }

      it "should include all repos" do
        expect(commits.keys[0]).to eq @repo_1.id
        expect(commits.keys[1]).to eq @repo_2.id
      end

      it "should have all commits data" do
        expect(same_commit_arrays?(commits.values[0], @repo_1.commits)).to be true
        expect(same_commit_arrays?(commits.values[1], @repo_2.commits)).to be true
      end
    end

    context "with valid custom params" do
      full_params = {from: "9 Feb 2015",
                     til: "9 March 2015",
                     by: "Nathan Dao",
                     in: "repo_1"}

      (1..4).to_a.each do |s|
        full_params.keys.combination(s).to_a.each do |combi|
          params = combi.inject({}) { |p, k|
            p.merge!({k => full_params[k]})
            p
          }

          context "#{params.to_s}" do
            it "should return return the correct commits data" do
              Ginatra::Stat.commits(params).each do |v|
                expect(same_commit_arrays?(v[1], get_repo(v[0]).commits(params))).to be true
              end
            end
          end
        end
      end
    end
  end
end
