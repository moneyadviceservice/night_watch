require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'night_watch/utilities'
require 'night_watch/rails_app'
require 'night_watch/rails_engine'

module NightWatch

  class VerifyCommit
    include Utilities::Workspace

    attr_reader :repo_to_validate_name, :ref_left, :ref_right, :repos

    def initialize(repo_to_validate_name, ref_left, ref_right, repos, workspace)
      self.workspace = workspace
      @repo_to_validate_name = repo_to_validate_name
      @ref_left = ref_left
      @ref_right = ref_right
      @repos = repos
    end

    def find_broken_dependants(dependants_details = {})
      broken = []

      with_each_dependant(dependants_details) do |app, urls_to_snapshot|
        diff = wraith.create_diff(app.name, urls_to_snapshot)
        app.prepare
        repo_to_validate.link_to(app)

        repo_to_validate.reset_to(ref_left)
        app.run { diff.snapshot_left }

        repo_to_validate.reset_to(ref_right)
        app.run { diff.snapshot_right }

        broken << app.name if diff.has_changes?
      end

      broken
    end

  private

    def wraith
      @wraith ||= Wraith.new(workspace)
        .tap { |w| w.setup }
    end

    def repo_to_validate
      @repo_to_validate ||= BowerRepoToValidate.new(repo_to_validate_name, repos.get_path(repo_to_validate_name))
        .tap { |r| r.setup }
    end

    def with_each_dependant(dependants_details, &block)
      apps = dependants_details.flat_map do |type, names_and_paths|
        app_class = "NightWatch::#{type.to_s.classify.singularize}".constantize

        names_and_paths.map do |name, paths|
          [app_class.new(name, repos.get_path(name)), paths]
        end
      end

      apps.each(&block)
    end

  end
end
