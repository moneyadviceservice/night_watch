require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'night_watch/utilities'
require 'night_watch/config_template'
require 'night_watch/rails_app'
require 'night_watch/rails_engine'

module NightWatch

  class VerifyCommit
    include Utilities::ScriptRunner

    attr_reader :repo_to_validate, :ref_to_validate, :repos, :workspace

    def initialize(repo_to_validate, ref_to_validate, repos, workspace)
      @repo_to_validate = repo_to_validate
      @ref_to_validate = ref_to_validate
      @repos = repos
      @workspace = workspace
    end

    def find_broken_dependants(dependants_details = {})
      broken = []

      with_repo_to_validate { sh("bower link") }

      in_workspace do
        sh("wraith setup")
        FileUtils.rm_rf("shots")
        FileUtils.mkdir("shots")
      end

      instantiate_dependants(dependants_details).each do |app|
        create_wraith_configs(app.name)
        with_repo_to_validate { sh("git fetch && git reset #{ref_to_validate} --hard && git clean -fd") }
        in_workspace { sh("wraith reset_shots #{app.name}-compare") }
        app.prepare do
          sh("bower install")
          sh("bower link #{repo_to_validate}")
        end
        app.run { save_images(app.name, 'current') }
        with_repo_to_validate { sh("git fetch && git reset #{ref_to_validate}~1 --hard && git clean -fd") }
        app.run { save_images(app.name, 'previous') }
        broken << app.name if images_differ?(app.name)
      end

      broken
    end

  private

    def in_workspace(&block)
      Dir.chdir(workspace, &block)
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

    CONFIG_TEMPLATES = Hash[
      %w( current previous compare ).map do |config|
        [config, ConfigTemplate.new(File.expand_path("config_templates/#{config}.yaml.erb", File.dirname(__FILE__)))]
      end
    ]

    def create_wraith_configs(name)
      in_workspace do
        CONFIG_TEMPLATES.each do |config, template|
          File.open("configs/#{name}-#{config}.yaml", 'w') do |file|
            file.write(template.generate(name))
          end
        end
      end
    end

    def save_images(app_name, state)
      in_workspace { sh("wraith save_images #{app_name}-#{state}") }
    end

    def images_differ?(app_name)
      in_workspace { sh("wraith crop_images #{app_name}-compare") }
      in_workspace { sh("wraith compare_images #{app_name}-compare") }

      Dir["#{workspace}/shots/#{app_name}/**/*_data.txt"].any? { |file| Float(File.read(file)) > 0.0 }
    end

  end
end
