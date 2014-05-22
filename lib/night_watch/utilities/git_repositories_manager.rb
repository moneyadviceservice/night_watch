require 'fileutils'

module NightWatch
  module Utilities
    class GitRepositoriesManager
      attr_reader :root_path
      attr_reader :origins

      def initialize(root_path, origins)
        @root_path = File.expand_path(root_path)
        @origins = Hash[
          origins.map do |uri|
            name = File.basename(uri[uri.rindex('/')+1..-1], '.git')
            [name, uri]
          end
        ]
      end

      def ensure_latest
        origins.each do |name, uri|
          if File.exists?(repo_location(name))
            repo_pull_all(name)
          else
            repo_clone(name, uri)
          end
        end
      end

      def create(force = false)
        prevent_overwrite unless force
        FileUtils.rm_rf(root_path) if File.exist?(root_path)
        FileUtils.mkdir_p(root_path)
        origins.each { |name, uri| repo_clone(name, uri) }
      end

      def with_repo(name)
        path = repo_location(name)
        Dir.chdir(path) { yield(path) }
      end

      def repo_location(name)
        File.join(root_path, name)
      end

    private

      def repo_clone(name, uri)
        path = repo_location(name)
        $stderr.puts "Cloning repository '#{uri}' into '#{path}'"
        $stderr.puts `git clone #{uri} #{path} 2>&1`
        $stderr.puts

        raise "Error cloning repository '#{uri}' into '#{path}'!" unless $?.exitstatus == 0
      end

      def repo_pull_all(name)
        with_repo(name) do |path|
          remote_url = `git config remote.$(git config branch.$(git name-rev --name-only HEAD).remote).url`.strip
          $stderr.puts "Pulling all from '#{remote_url}' into '#{path}'"
          $stderr.puts `git fetch --all 2>&1`
          $stderr.puts `git reset --hard origin/master 2>&1`
          $stderr.puts

          raise "Error pulling all from '#{remote_url}' into '#{path}'!" unless $?.exitstatus == 0
        end
      end

      def prevent_overwrite
        raise "Repos location '#{root_path}' already exists. Use --force to overwrite." if File.exist?(root_path)
      end

    end
  end
end
