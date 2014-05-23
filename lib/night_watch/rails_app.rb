require 'night_watch/utilities'

module NightWatch
  class RailsApp
    include Utilities::ScriptRunner

    attr_reader :name, :path

    def initialize(name, path)
      @name = name
      @path = path
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
      bundle_install
      bower_install
      in_path(&block) unless block.nil?
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
      path
    end

    def in_rails_root
      Dir.chdir(rails_root) { yield }
    end

    def in_path(&block)
      Dir.chdir(path, &block)
    end

    def bundle_install
      in_rails_root { sh_with_rvm("bundle install") }
    end

    def bower_install
      in_path { "bower install" }
    end

    def sh_with_rvm(command)
      sh("rvm #{rvm_environment} do #{command}")
    end

    def rvm_environment
      @rvm_environment ||= begin
        ruby_version = IO.read(File.join(path, '.ruby-version')).chomp
        ruby_gemset = IO.read(File.join(path, '.ruby-gemset')).chomp

        "#{ruby_version}@#{ruby_gemset}"
      end
    end

  end
end
