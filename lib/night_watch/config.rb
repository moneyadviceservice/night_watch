require 'yaml'

module NightWatch
  class Config
    FILE_NAME = '.nightwatch'

    class << self

      def method_missing(method, *arguments, &block)
        (arguments.size > 0 || block) ? super : get(method)
      end

      def get(key)
        config_data[key.to_s]
      end

      def config_path=(value)
        @config = nil
        @config_path = value
      end

      def config_path
        @config_path ||= find_config_path
      end

    private

      def config_data
        @config ||= begin
          raise 'Config not found. See `$ nightwatch --help` for usage and configuration instructions' unless File.exists?(config_path.to_s)
          YAML.load_file(config_path)
        end
      end

      def find_config_path
        config_path = nil
        Dir.chdir(Dir.pwd) do
          dir = '.'
          while config_path == nil && File.expand_path(dir) != File::Separator do
              potential_config_path = File.expand_path(FILE_NAME, dir)
              config_path = potential_config_path if File.exists?(potential_config_path)
              dir = File.join(dir, '..')
          end
        end

        config_path
      end

    end
  end
end
