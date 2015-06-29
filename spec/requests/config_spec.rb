require_relative '../spec_helper'

RSpec.describe Ginatra::Config do
  include_context "dummy test app"

  describe "settings" do
    before {
      @settings = Ginatra::Config.settings
      @repos_dir = GinatraSpecHelper::REPOS_DIR
      @colors = ['#ce0000','#114b5f','#f7d708','#028090',
                 '#9ccf31','#ff9e00', '#e4fde1','#456990',
                 '#ff9e00','#f45b69']
    }

    it "should have the correct repos" do
      @settings["repositories"].each do |repo|
        repo_id = repo[0]
        repo_name = repo_id == 'repo_1' ? "First Repository" : "Second Repository"

        expect(repo[1]["path"]).to eq("#{@repos_dir}/#{repo_id}")
        expect(repo[1]["name"]).to eq(repo_name)
      end
    end

    it "should have the correct default color array" do
      @colors.each_with_index do |color, i|
        expect(@settings["colors"][i]).to eq(color)
      end
    end

    it "should have the correct threshold value" do
      expect(@settings["threshold"]).to eq(3)
    end

    it "should have the correct sprint information" do
      expect(@settings["sprint"]["period"]).to eq(14)
      expect(@settings["sprint"]["reference_date"]).to eq('3 June 2015')
    end
  end
end
