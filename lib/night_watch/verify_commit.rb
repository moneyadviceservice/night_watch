require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'night_watch/utilities'
require 'night_watch/config_template'
require 'night_watch/rails_app'
require 'night_watch/rails_engine'

module NightWatch

  class VerifyCommit
    include Utilities::ScriptRunner
    include Utilities::Workspace

    attr_reader :repo_to_validate, :ref_to_validate, :repos

    def initialize(repo_to_validate, ref_to_validate, repos, workspace)
      self.workspace = workspace
      @repo_to_validate = repo_to_validate
      @ref_to_validate = ref_to_validate
      @repos = repos
    end

    def find_broken_dependants(dependants_details = {})
      broken = []

      with_repo_to_validate { sh("bower link") }

      instantiate_dependants(dependants_details).each do |app|
        diff = wraith.create_diff(app.name)
        with_repo_to_validate { sh("git fetch && git reset #{ref_to_validate} --hard && git clean -fd") }
        app.prepare { sh("bower link #{repo_to_validate}") }
        app.run { diff.snapshot_current }
        with_repo_to_validate { sh("git fetch && git reset #{ref_to_validate}~1 --hard && git clean -fd") }
        app.run { diff.snapshot_previous }
        broken << app.name if diff.has_changes?
      end

      broken
    end

  private

    def wraith
      @wraith ||= Wraith.new(workspace).tap { |w| w.setup }
    end

    def with_repo_to_validate(&block)
      Dir.chdir(repo_to_validate_path, &block)
    end

    def repo_to_validate_path
      @repo_to_validate_path ||= repos.get_path(repo_to_validate)
    end

    def instantiate_dependants(dependants_details)
      dependants_details.flat_map do |type, names|
        app_class = "NightWatch::#{type.to_s.classify.singularize}".constantize

        names.map { |name| app_class.new(name, repos.get_path(name)) }
      end
    end

  end
end
