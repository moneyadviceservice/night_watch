require 'bundler'

module NightWatch
  module Utilities
    module ScriptRunner
    protected
      def sh(command, return_std_out = false)
        to_run = command.dup
        to_run << ' 1>&2' unless return_std_out

        $stderr.puts "run: #{command}"
        $stderr.puts "in: #{`pwd`}"
        output = Bundler.with_clean_env { `#{to_run}` }
        $stderr.puts

        raise "Error running command: #{command}\nExit status: #{$?.exitstatus}" unless $?.success?

        output
      end
    end
  end
end
