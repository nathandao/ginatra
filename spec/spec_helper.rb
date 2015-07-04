require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rack/test'
require 'sinatra'
require 'fileutils'

require_relative '../lib/ginatra'
require_relative 'factory'

module Ginatra
  class App < Sinatra::Base
    set :environment, :test
    set :data, Ginatra::Env.data || ::File.expand_path('../../test/dummy/data/', ::File.dirname(__FILE__))
  end
end

module GinatraDummy
  DUMMY_DIR = File.expand_path('../test/dummy', File.dirname(__FILE__))
  REPOS_DIR = File.expand_path('repos/', DUMMY_DIR)
  REPOS = %w{ https://github.com/nathandao/ginatra_dummy_1.git
              https://github.com/nathandao/ginatra_dummy_2.git }

  def create_test_dummy
    unless dummy_exists?
      create_dummy_directory
      pull_dummy_repos
      create_config_yml
    end
  end

  def destroy_test_dummy
    if dummy_exists?
      remove_dummy_directory
    end
  end

  private

  def dummy_exists?
    File.directory?(DUMMY_DIR)
  end

  def pull_dummy_repos
    REPOS.each_with_index do |repo, i|
      `git clone #{repo} #{REPOS_DIR}/repo_#{i+1}`
    end
  end

  def create_config_yml
    puts config_yml_content
    File.open(File.expand_path('./config.yml', GinatraDummy::DUMMY_DIR), 'w') { |f|
      f.write(config_yml_content)
    }
  end

  def config_yml_content
    "
repositories:
  repo_1:
    path: #{GinatraDummy::REPOS_DIR}/repo_1
    name: First Repository
  repo_2:
    path: #{GinatraDummy::REPOS_DIR}/repo_2
    name: Second Repository

colors: ['#ce0000','#114b5f','#f7d708','#028090','#9ccf31','#ff9e00','#e4fde1','#456990','#ff9e00','#f45b69']

threshold: 3
sprint:
  period: 14
  reference_date: 3 June 2015
"
  end

  def create_dummy_directory
    FileUtils.mkdir_p(GinatraDummy::DUMMY_DIR)
  end

  def remove_dummy_directory
    FileUtils.rm_r(GinatraDummy::DUMMY_DIR)
  end
end

module GinatraSpecHelper
  def undo_commits(repo_id, count = 1)
    repo = Ginatra::Helper.get_repo(repo_id)
    `git -C '#{repo.path}' reset --hard HEAD~#{count} >> /dev/null 2>&1`
  end

  def remove_data_file(repo_id)
    if File.exists?(repo_data_path(repo_id))
      FileUtils.rm(repo_data_path(repo_id))
    end
  end

  def repo_data_path(repo_id)
    File.expand_path("./data/.#{repo_id}", GinatraDummy::DUMMY_DIR)
  end

  def commit_id(commit)
    commit.first[0]
  end

  def commit_data(commit)
    commit.values[0]
  end

  def same_commit_arrays?(c_1, c_2)
    c_1 | c_2 == c_1
  end

  def repo_commits_overview(repo)
    init = {commits_count: 0 , additions: 0, deletions: 0, lines: 0,
            hours: 0, last_commit: '', first_commit: ''}

    repo.commits.inject(init) { |result, v|
      result[:commits_count] += 1
      result[:additions] += v
    }
  end

  def commit_additions(commit)
    changes = commit.flatten[1]['changes']
    if changes
      changes.inject(0) { |sum, v|
        sum += v['deletions'] if v['deletions']
        sum
      }
    else
      0
    end
  end
end

RSpec.configure do |config|
  config.include(GinatraSpecHelper)
  config.include(GinatraDummy)
  config.include(GinatraFactory)

  config.before(:all) do
    Ginatra::App.root = GinatraDummy::DUMMY_DIR
    Ginatra::App.data = GinatraDummy::DUMMY_DIR + '/data'
    create_test_dummy
  end

  config.after(:all) do
    # destroy_test_dummy
  end
end
