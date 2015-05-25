require 'rubygems'
require 'bundler/setup'
require 'sinatra'

# $: << File.dirname(__FILE__) + "lib/"


get '/' do
  repo_path = "~/Sites/vagrant-nesteoil/git/nesteoil"
  commits = []
  log_params = "--pretty=full --full-history --shortstat"
  log_format = '"commit=>%h, author=>%an, dade=>%ai<--ginatra-entry-->"'

  commit_logs = `git -C #{repo_path} log #{log_params} --format=#{log_format}`.split("<--ginatra-entry-->")

  commit_logs.each do |commit_log|
    c_meta = Hash.new()

    commit_log.split("\n").each do |commit_part|
      next unless !commit_part.empty?

      if (commit_part.index('commit=>') == 0)
        commit_part.split(/, /).inject(Hash.new{ |h, k| h[k] = nil }) do |h, s|
          k,v = s.split(/=>/)
          h[k] = v
          c_meta = [c_meta, h].inject(&:merge)
        end
      end
    end
    commits << c_meta
  end

  commits
end
