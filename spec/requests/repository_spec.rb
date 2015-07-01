# -*- coding: utf-8 -*-
require_relative '../spec_helper.rb'

shared_examples "invalid repository" do
  it "should return false" do
    expect(Ginatra::Repository.new(params)).to be false
  end
end

describe Ginatra::Repository do
  context "initialize" do
    context "with valid information" do
      before(:each) do
        @repo= get_repo('repo_1')
        @repos_dir = GinatraDummy::REPOS_DIR
      end

      it "should have the correct id" do
        expect(@repo.id).to eq "repo_1"
      end

      it "should have the correct path" do
        expect(@repo.path).to eq "#{@repos_dir}/repo_1"
      end

      it "should have the correct name" do
        expect(@repo.name).to eq "First Repository"
      end

      it "should have the correct color" do
        expect(@repo.color).to eq "#ce0000"
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

  describe "authors" do
    let(:repo) { get_repo('repo_1') }
    let(:authors_hash) { repo.authors }
    let(:authors) { authors_hash.map { |v| v['name'] } }
    let(:expected_authors) { ["Joe Hudson", "Nathan Dao", "bultas",
                              "David Ascher", "aaronhayes", "Steven Dickinson",
                              "Toni Cárdenas", "Neo Alienson", "jefffriesen",
                              "Peter Halliday", "Eric Tse"] }

    it "should return the correct authors" do
      expect(authors & expected_authors).to eq authors
    end

    let(:expected_author_data) { [{"name"=>"Joe Hudson", "commits"=>49, "additions"=>1167, "deletions"=>881},
                                  {"name"=>"Nathan Dao", "commits"=>1, "additions"=>5, "deletions"=>1},
                                  {"name"=>"bultas", "commits"=>1, "additions"=>1, "deletions"=>1},
                                  {"name"=>"David Ascher", "commits"=>1, "additions"=>1, "deletions"=>1},
                                  {"name"=>"aaronhayes", "commits"=>3, "additions"=>19, "deletions"=>3},
                                  {"name"=>"Steven Dickinson", "commits"=>1, "additions"=>295, "deletions"=>1},
                                  {"name"=>"Toni Cárdenas", "commits"=>1, "additions"=>6, "deletions"=>5},
                                  {"name"=>"Neo Alienson", "commits"=>1, "additions"=>1, "deletions"=>1},
                                  {"name"=>"jefffriesen", "commits"=>1, "additions"=>35, "deletions"=>3},
                                  {"name"=>"Peter Halliday", "commits"=>1, "additions"=>27, "deletions"=>27},
                                  {"name"=>"Eric Tse", "commits"=>1, "additions"=>4, "deletions"=>4}] }

    it "should return the correct author data" do
      authors_hash.each do |author|
        expected_author = expected_author_data.select { |v|
          v['name'] == author['name']
        }.first

        author.each do |key, val|
          expect(val).to eq expected_author[key]
        end
      end
    end
  end
end
