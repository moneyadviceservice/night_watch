require 'night_watch/utilities'
require 'night_watch/wraith_diff'

module NightWatch
  class Wraith
    include Utilities::ScriptRunner
    include Utilities::Workspace

    def initialize(workspace)
      self.workspace = workspace
    end

    def setup
      in_workspace do
        sh("wraith setup")
        FileUtils.rm_rf("shots")
        FileUtils.mkdir("shots")
      end
    end

    def create_diff(name, paths)
      diff = WraithDiff.new(name, paths, workspace)
      diff.setup

      diff
    end
  end
end
