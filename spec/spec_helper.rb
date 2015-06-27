require 'rspec'
require 'rack/test'
require 'sinatra'
require 'test/unit'
require 'fileutils'
require_relative '../../lib/ginatra.rb'

module Ginatra
  class App < Sinatra::Base
    set :environment, :test
    set :root, Ginatra::Env.root || ::File.expand_path('../../test/dummy', ::File.dirname(__FILE__))
    set :data, Ginatra::Env.data || ::File.expand_path('../../test/dummy/data/', ::File.dirname(__FILE__))
  end
end

module GinatraTestHelper
  DUMMY_DIR = File.expand_path('../../test/dummy', File.dirname(__FILE__))
  REPO_1 = 'git@github.com:nathandao/ginatra_dummy_1.git'
  REPO_2 = 'git@github.com:nathandao/ginatra_dummy_2.git'

  def init_test_dummy
    unless dummy_exists?
      FileUtils.mkdir_p(GinatraHelper::DUMMY_DIR)
      `git clone #{REPO_1} #{DUMMY_DIR}`
      `git clone #{REPO_2} #{DUMMY_DIR}`
    end
  end

  def destroy_test_dummy
    unless dummy_exists?
      FileUtils.rm_r(Ginatra::Helper::DUMMY_DIR)
    end
  end

  private

  def dummy_exists?
    File.directory?(DUMMY_DIR)
  end
end
