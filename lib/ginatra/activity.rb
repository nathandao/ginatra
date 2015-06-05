require 'chronic'

module Ginatra
  class Activity
    class << self
      def hours params = {}
        # all repos
        Ginatra::Stat.commits(params).inject({}) { |result, repo|
          repo_id = repo[0]
          commits = repo[1]
          result[repo_id] = commits.group_by { |commit|
            commit.flatten[1]['author']
          }.map { |author, c|
            c = Ginatra::Helper.sort_commits c, by: 'date', order: 'desc'
            { 'author' => author, 'hours' => compute_hours(c) }
          }
          result
        }
      end

      private

      def compute_hours commits
        # get all hours from commits array
        # commits array should be from
        # the same author and repository
        commits = Ginatra::Helper.sort_commits commits, by: 'date', order: 'desc'
        prev_time = nil
        threshold = Ginatra::Config.threshold.to_f * 60 * 60
        commits.inject(0.00) { |dev_time, commit|
          commit_time = commit.flatten[1]['date']
          unless prev_time.nil?
            session = prev_time - commit_time
            if session <= threshold
              dev_time += session
            else
              prev_time = nil
            end
          else
            prev_time = commit_time
            dev_time += threshold / 2
          end
          dev_time
        } / 60 / 60
      end
    end
  end
end
