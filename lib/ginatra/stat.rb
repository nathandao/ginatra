module Ginatra
  class Stat
    class << self
      def commits repo_id
        get_repo(repo_id).commits
      end

      def commits_between repo_id, date_range = []
        get_repo(repo_id).commits_between date_range
      end

      def all_commits
        all_commits_between ['1/1/1', 'now']
      end

      def all_commits_between date_range = []
        repos = Ginatra::Config.repositories
        repos.inject(Hash.new) { |output, repo|
          id = repo[0]
          params = repo[1].merge({'id' => id})
          output[id] = Repository.new(params).commits_between date_range
          output
        }
      end

      def authors repo_id
        get_repo(repo_id).commits.group_by { |commit|
          commit.first[1]['author']
        }.map { |name, commits|
          {
           'name' => name,
           'commits' => commits.size,
           'additions' => get_additions(commits),
           'deletions' => get_deletions(commits)
          }
        }
      end

      def lines repo_id
        lines_between repo_id, []
      end

      def lines_between repo_id, date_range = []
        commits = get_repo(repo_id).commits_between date_range
        commits.inject(0) { |line_count, commit|
          changes = commit.flatten[1]["changes"]
          line_count += changes.inject(0) { |c_line_count, change|
            c_line_count -= change['deletions']
            c_line_count += change['additions']
          } unless changes.empty?
          line_count
        }
      end

      def all_lines
        all_lines_between []
      end

      def all_lines_between date_range = []
        repos = Ginatra::Config.repositories
        repos.inject(Hash.new) { |lines, repo|
          id = repo[0]
          lines[id] = lines_between id, date_range
          lines
        }
      end

      def refresh_all_data
        repos = Ginatra::Config.repositories
        repos.each do |key, params|
          params = params.merge({'id' => key})
          Ginatra::Repository.new(params).refresh_data
        end
      end

      private

      def get_repo repo_id
        repo = Ginatra::Config.repositories[repo_id]
        return nil if repo.nil?
        repo['id'] = repo_id
        Ginatra::Repository.new repo
      end

      def get_commit_value commits, key
        value = 0
        commits.each do |commit|
          commit.each do |k, v|
            v['changes'].each do |change|
              value += change[key] unless change[key].nil?
            end
          end
        end
        value
      end

      def get_additions commits
        get_commit_value commits, 'additions'
      end

      def get_deletionsx commits
        get_commit_value commits, 'deletions'
      end
    end
  end
end
