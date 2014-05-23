module NightWatch
  module Utilities
    module Workspace
      attr_accessor :workspace

      def workspace=(value)
        @workspace = File.expand_path(value)
      end

      def in_workspace(&block)
        raise "No workspace set" if workspace.nil?
        Dir.chdir(workspace, &block)
      end
    end
  end
end
