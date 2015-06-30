require_relative '../spec_helper.rb'

RSpec.describe Ginatra::Repository do
  context "when valid" do
    before(:each) do
      @repo_1 = get_repo('repo_1')
      @repo_2 = get_repo('repo_2')
      @repos_dir = GinatraDummy::REPOS_DIR
    end

    it "should have the correct id" do
      expect(@repo_1.id).to eq('repo_1')
      expect(@repo_2.id).to eq('repo_2')
    end

    it "should have the correct path" do
      expect(@repo_1.path).to eq("#{@repos_dir}/repo_1")
      expect(@repo_2.path).to eq("#{@repos_dir}/repo_2")
    end

    it "should have the correct name" do
      expect(@repo_1.name).to eq("First Repository")
      expect(@repo_2.name).to eq("Second Repository")
    end

    it "should have the correct color" do
      expect(@repo_1.color).to eq('#ce0000')
      expect(@repo_2.color).to eq('#114b5f')
    end

    it "should have the correct commits count" do
      # We are only checking for commit size at the moment
      # Need a better fool proof test for this?
      expect(@repo_1.commits.size).to eq(61)
      expect(@repo_2.commits.size).to eq(593)
    end
  end

  context "when invalid" do
    before(:each) do
      # Use repository 1 as default
      @repo = get_repo('repo_1')
    end
  end
end
