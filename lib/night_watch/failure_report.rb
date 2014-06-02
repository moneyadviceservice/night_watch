require 'night_watch/utilities'

module NightWatch
  class FailureReport
    include Utilities::Workspace
    include Utilities::ScriptRunner

    def initialize(repo_to_validate, ref_to_validate, broken_dependants, workspace)
      self.workspace = workspace
      @repo_to_validate = repo_to_validate
      @ref_to_validate = ref_to_validate
      @broken_dependants = broken_dependants
    end

    def generate
      write_readme
      create_tarball
    end

    def path
      @path ||= File.join(workspace, "#{repo_to_validate}_#{ref_to_validate}_issues.tar.gz")
    end

  private

    attr_reader :repo_to_validate, :ref_to_validate, :broken_dependants

    def write_readme
      in_workspace do
        File.open('readme.txt', 'w') do |f|
          f.puts "Repo to validate: #{repo_to_validate}"
          f.puts "Ref to validate: #{ref_to_validate}"
          f.puts "Broken dependants:"
          f.puts *broken_dependants.map { |bd| " - #{bd}"}
        end
      end
    end

    def create_tarball
      in_workspace { sh("tar -cvzf #{path} #{tarball_contents.join(' ')}") }
    end

    def tarball_contents
      broken_dependants.map { |bd| "shots/#{bd}" } + ['readme']
    end

  end
end
