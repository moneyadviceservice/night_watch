require 'night_watch/utilities'

module NightWatch
  class RefResolver
    include Utilities::ScriptRunner
    include Utilities::Workspace

    def initialize(workspace)
      self.workspace = workspace
    end

    def find_baseline(ref)
      parents = all_parent_commits_for(ref)
      raise "Ref #{ref} has no parent!" if parents.empty?

      parents.one? ? parents.first : merge_base_of(parents)
    end

  private

    attr_reader :repos, :repo_name

    def all_parent_commits_for(ref)
      in_workspace { sh("git show #{ref}^@ --quiet --pretty=format:%H", true).lines.map(&:chomp) }
    end

    def merge_base_of(refs)
      in_workspace { sh("git merge-base #{refs.join(' ')}", true).chomp }
    end

  end
end
