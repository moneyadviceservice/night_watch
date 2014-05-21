require 'night_watch/utilities'
require 'night_watch/config_template'

module NightWatch
  class VerifyCommit
    include Utilities::ScriptRunner

    CONFIG_TEMPLATES = Hash[
      %w( current previous compare ).map do |config|
        [config, ConfigTemplate.new(File.expand_path("config_templates/#{config}.yaml.erb", File.dirname(__FILE__)))]
      end
    ]

    attr_reader :repo_to_validate, :ref_to_validate, :repo_manager, :workspace

    def initialize(repo_to_validate, ref_to_validate, repo_manager, workspace)
      @repo_to_validate = repo_to_validate
      @ref_to_validate = ref_to_validate
      @repo_manager = repo_manager
      @workspace = workspace
    end

    def find_broken_dependants(apps: [], engines: [])
      broken = []

      run_in_workspace("wraith setup")

      repo_manager.with_repo(repo_to_validate) do
        run("bower link")
      end

      in_workspace do
        FileUtils.rm_rf('shots')
        FileUtils.mkdir('shots')
      end

      Array(apps).each do |app|
        rails_server_pid = nil

        create_configs(app)

        run_in_workspace("wraith reset_shots #{app}-compare")

        repo_manager.with_repo(repo_to_validate) do
          run("git fetch && git reset #{ref_to_validate} --hard && git clean -fd")
        end

        repo_manager.with_repo(app) do
          run_with_rvm("bundle install")
          run("bower install")
          run("bower link #{repo_to_validate}")
          run_with_rvm("bundle exec rails s -d -p 3000")
          rails_server_pid = IO.read("tmp/pids/server.pid") rescue raise("Rails didn't appear to start!")
        end

        run_in_workspace("wraith save_images #{app}-current")
        run_in_workspace("kill -9 #{rails_server_pid}")

        repo_manager.with_repo(repo_to_validate) do
          run("git fetch && git reset #{ref_to_validate}~1 --hard && git clean -fd")
        end

        repo_manager.with_repo(app) do
          FileUtils.rm_rf("public/assets")
          run_with_rvm("bundle exec rails s -d -p 3000")
          rails_server_pid = IO.read("tmp/pids/server.pid") rescue raise("Rails didn't appear to start!")
        end

        run_in_workspace("wraith save_images #{app}-previous")

        run_in_workspace("kill -9 #{rails_server_pid}")

        run_in_workspace("wraith crop_images #{app}-compare")
        run_in_workspace("wraith compare_images #{app}-compare")

        screenshots_differ = Dir["#{workspace}/shots/#{app}/**/*_data.txt"].any? { |file| Float(File.read(file)) > 0.0 }

        broken << app if screenshots_differ
      end

      broken
    end

  private

    def in_workspace(&block)
      Dir.chdir(workspace, &block)
    end

    def run_in_workspace(command)
      in_workspace { run(command) }
    end

    def run_with_rvm(command)
      run("rvm $(cat .ruby-version)@$(cat .ruby-gemset) do #{command}")
    end

    def create_configs(name)
      CONFIG_TEMPLATES.each do |config, template|
        in_workspace do
          File.open("configs/#{name}-#{config}.yaml", 'w') do |file|
            file.write(template.generate(name))
          end
        end
      end
    end

  end
end
