require 'rspec'
require_relative '../../lib/ginatra/app.rb'

RSpec.describe Ginatra::Repository do
  describe '#path' do
    it "should have local path" do
      expect(repo_1.path).to eq ::File.expand_path('../../test/dummy/ginatra_dummy_1', DIR(__FILE__))
    end
  end
end
