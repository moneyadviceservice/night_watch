require 'night_watch/utilities'

module NightWatch
  class FailureReport
    include Utilities::Workspace
    include Utilities::ScriptRunner

    def initialize(repo, ref_range_to_validate, ref_baseline, broken_dependants, workspace)
      self.workspace = workspace
      @repo = repo
      @ref_range_to_validate = ref_range_to_validate
      @ref_baseline = ref_baseline
      @broken_dependants = broken_dependants
    end

    def generate
      write_readme
      create_tarball
    end

    def path
      @path ||= File.join(workspace, "#{repo}_#{ref_range_to_validate}_issues.tar.gz")
    end

  private

    attr_reader :repo, :ref_range_to_validate, :ref_baseline, :broken_dependants

    def write_readme
      in_workspace do
        File.open('readme.txt', 'w') do |f|
          f.puts "Repo: #{repo}"
          f.puts "Problem ref: #{ref_range_to_validate}"
          f.puts "Validated against: #{ref_baseline}"
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
