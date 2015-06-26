require 'rspec'
require_relative '../lib/ginatra/app.rb'

RSpec.describe Ginatra::Repository do
  before do
    @repo = Ginatra::Repository.new
  end
  describe '#path' do
    it "should have local path" do
      expect(repo.path).to eq('~/ruby-wife/ginatra')
    end
  end
end
