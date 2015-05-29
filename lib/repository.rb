require 'json'
require_relative 'helpers'

module Ginatra
  class Repository
    attr_accessor :id, :path, :name, :commits

    def initialize(id, name, path)
      @id = id
      @path = path
      @name = name
      @commits = nil
    end

    def commits
      get_commits if @commits.nil?
      return @commits
    end

    private

    def get_commits
      code = %s{
               markers = %w{ id author date }
               if $F.empty?
                 puts "\"changes\": ["
               else
                 key = $F[0]
                 if markers.include? key
                   $F.shift
                   value = $F.inject { |o, n| o + " " + n }
                   puts key == "id" ? "]\}\},\{\"#{$F[0]}\":\{" : "\"#{key}\": \"#{value}\","
                 else
                   add = $F[0]
                   del = $F[1]
                   file = $F[2]
                   puts "{\"additions\": #{add}, \"deletions\": #{del}, \"path\": \"#{file}\"},"
                 end
               end
               }
      wrapper = %s{ BEGIN{puts "["}; END{puts "]\}\}]"} }
      json_str =  `git -C #{@path} log \
                   --numstat \
                   --format='id %h%nauthor %an%ndate %ai' $@ | \
                   ruby -lawne '#{code}' | \
                   ruby -wpe '#{wrapper}' | \
                   tr -d '\n' | \
                   sed "s/,]/]/g; s/]}},//"
      `
      @commits = JSON.parse(json_str)
    end
  end
end
