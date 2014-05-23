require 'night_watch/utilities'

module NightWatch
  class RepoToValidate
    include Utilities::ScriptRunner
    include Utilities::Workspace

    attr_reader :name

    def initialize(name, path)
      self.workspace = path
      @name = name
    end

    def setup
      # implement me!
    end

    def link_to(app)
      raise "#link_to must be overridden in specific child classes"
    end

    def reset_to(ref)
      in_workspace { sh("git fetch && git reset #{ref} --hard && git clean -fd") }
    end
  end
end
