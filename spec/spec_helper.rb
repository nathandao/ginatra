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

  def commit_author(commit)
    commit_data(commit)['author']
  end

  def same_commit_authors?(c_1, c_2)
    commit_author(c_1) == commit_author(c_2)
  end

  def commit_dates(commit)
    Time.new(commit_data(commit)['date'])
  end

  def same_commit_dates?(c_1, c_2)
    commit_date(c_1) == commit_date(c_2)
  end

  def commit_changes(commits)
    commit_data(commit)['changes']
  end

  def same_commit_changes?(c_1, c_2)
    ch_1 = commit_changes(c_1)
    ch_2 = commit_changes(c_2)
    ch_1 | ch_2 == c_1
  end

  def same_commits?(c_1, c_2)
    id_1 = commit_id(c_1)
    id_2 = commit_id(c_2)
    if id_1 == id_2
      if same_commit_dates?(c_1, c_2) and
          same_commit_authors?(c_1, c_2) and
          same_commit_changes?(c_1, c_2)
        true
      else
        false
      end
    else
      false
    end
  end

  def same_commit_arrays?(c_1, c_2)
    c_1 | c_2 == c_1
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
