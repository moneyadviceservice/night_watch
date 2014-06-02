require 'night_watch/utilities'

module NightWatch
  class RailsApp
    include Utilities::ScriptRunner
    include Utilities::Workspace

    attr_reader :name

    def initialize(name, path)
      self.workspace = path
      @name = name
    end

    def run(&block)
      start
      block.call
    ensure
      stop
    end

    def start
      in_rails_root { sh_with_rvm("bundle exec rails s -d -p 3333") }
      raise "Could not start application #{name}" unless running?
    end

    def stop
      sh("kill -9 #{pid}") if running?
    end

    def prepare(&block)
      ensure_rvm_gemset
      bundle_install
      bower_install
      in_workspace(&block) unless block.nil?
    end

    def running?
      !pid.nil?
    end

    def pid
      IO.read(File.join(rails_root, 'tmp', 'pids', 'server.pid'))
    rescue Errno::ENOENT
      nil
    end


  protected

    def rails_root
      workspace
    end

    def in_rails_root
      Dir.chdir(rails_root) { yield }
    end

    def bundle_install
      in_rails_root { sh_with_rvm("bundle install") }
    end

    def bower_install
      in_workspace { "bower install" }
    end

    def ensure_rvm_gemset
      sh_with_rvm("rvm gemset create #{ruby_gemset}")
    end

    def sh_with_rvm(command)
      sh("rvm #{rvm_environment} do #{command}")
    end

    def rvm_environment
      @rvm_environment ||= "#{ruby_version}@#{ruby_gemset}"
    end

    def ruby_gemset
      @ruby_gemset ||= IO.read(File.join(workspace, '.ruby-gemset')).chomp
    end

    def ruby_version
      @ruby_version ||= IO.read(File.join(workspace, '.ruby-version')).chomp
    end

  end
end
