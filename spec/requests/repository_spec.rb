require_relative '../spec_helper.rb'

shared_examples "invalid repository" do
  it "should return false" do
    expect(Ginatra::Repository.new(params)).to be false
  end
end

RSpec.describe Ginatra::Repository do
  context "initialize" do
    context "with valid information" do
      before(:each) do
        @repo_1 = get_repo('repo_1')
        @repo_2 = get_repo('repo_2')
        @repos_dir = GinatraDummy::REPOS_DIR
      end

      it "should have the correct id" do
        expect(@repo_1.id).to eq "repo_1"
        expect(@repo_2.id).to eq "repo_2"
      end

      it "should have the correct path" do
        expect(@repo_1.path).to eq "#{@repos_dir}/repo_1"
        expect(@repo_2.path).to eq "#{@repos_dir}/repo_2"
      end

      it "should have the correct name" do
        expect(@repo_1.name).to eq "First Repository"
        expect(@repo_2.name).to eq "Second Repository"
      end

      it "should have the correct color" do
        expect(@repo_1.color).to eq "#ce0000"
        expect(@repo_2.color).to eq "#114b5f"
      end
    end

    context "with invalid info:" do
      before(:each) do
        # Use repository 1 as default
        @repo = get_repo("repo_1")
        @params = {"id" => @repo.id,
                   "path" => @repo.path,
                   "name" => @repo.name}
      end

      %w{id path name}.each do |key|
        context "missing #{key}" do
          before { @params[key] = nil }
          let(:params) { @params }
          include_examples "invalid repository"
        end
      end

      context "invalid path" do
        before { @params['path'] = "/ginatra/random/path" }
        let(:params) { @params }
        include_examples "invalid repository"
      end

      context "invalid id" do
        before { @params['id'] = "invalid_repo" }
        let(:params) { @params }
        include_examples "invalid repository"
      end
    end
  end

  describe "commits data behaviours" do
    before(:each) do
      @repo = get_repo('repo_1')
    end

    it "should have the correct commits count" do
      # We are only checking for commit size at the moment
      # Need a better fool proof test for this?
      expect(@repo.commits.size).to eq 61
    end

    context "when no data file exists" do
      before { remove_data_file('repo_1') }

      it "should retrieve commits and create new data file" do
        expect(@repo.commits.size).to eq 61
        expect(File.exists?(repo_data_path(@repo.id))).to be true
      end
    end

    context "on refresh" do
      before do
        undo_commits(@repo.id, 5)
        remove_data_file(@repo.id)
      end

      describe "before" do
        it "should have the old commits count" do
          expect(@repo.commits.size).to eq 49
        end
      end

      describe "after" do
        before { @repo.refresh_data }
        it "should have the new commits count" do
          expect(@repo.commits.size).to eq 61
        end
      end
    end
  end
end
