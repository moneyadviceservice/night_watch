require 'night_watch/utilities'
require 'night_watch/wraith_config_template'
require 'set'

module NightWatch
  class WraithDiff
    include Utilities::ScriptRunner
    include Utilities::Workspace

    attr_reader :name, :paths

    def initialize(name, paths, workspace)
      self.workspace = workspace
      @name = name
      @paths = paths
      @saved = Set.new
    end

    def setup
      create_wraith_configs
      clear_old_images
    end

    def snapshot_current
      save_images(:current)
    end

    def snapshot_previous
      save_images(:previous)
    end

    def has_changes?
      ensure_ready_for_diff

      in_workspace { sh("wraith crop_images #{name}-compare") }
      in_workspace { sh("wraith compare_images #{name}-compare") }

      Dir["#{workspace}/shots/#{name}/**/*_data.txt"].any? { |file| Float(File.read(file)) > 0.0 }
    end

  private
    attr_reader :saved

    CONFIG_TEMPLATES = Hash[
      %w( current previous compare ).map do |config|
        template_path = File.expand_path("wraith_config_templates/#{config}.yaml.erb", File.dirname(__FILE__))

        [config, WraithConfigTemplate.new(template_path)]
      end
    ]

    def create_wraith_configs
      in_workspace do
        CONFIG_TEMPLATES.each do |config, template|
          File.open("configs/#{name}-#{config}.yaml", 'w') do |file|
            file.write(template.generate(name, paths))
          end
        end
      end
    end

    def clear_old_images
      in_workspace { sh("wraith reset_shots #{name}-compare") }
    end

    def save_images(state)
      in_workspace { sh("wraith save_image #{name}-#{state}")}
      saved << state
    end

    def ensure_ready_for_diff
      unless [:previous, :current].all? { |s| saved.include?(s) }
        raise "You must snapshot current and previous state before comparing images"
      end
    end

  end
end
