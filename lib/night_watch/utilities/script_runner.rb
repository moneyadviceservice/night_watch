require 'bundler'

module NightWatch
  module Utilities
    module ScriptRunner
    protected
      def sh(command)
        $stderr.puts "run: #{command}"
        $stderr.puts "in: #{`pwd`}"
        Bundler.with_clean_env { `#{command} 1>&2` }
        $stderr.puts

        raise "Error running command: #{command}\nExit status: #{$?.exitstatus}" unless $?.success?
      end
    end
  end
end
