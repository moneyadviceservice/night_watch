require 'night_watch/rails_app'

module NightWatch
  class RailsEngine < RailsApp

  protected

    def rails_root
      File.join(super, 'spec', 'dummy')
    end

    def bundle_install
      FileUtils.rm_rf(File.join(workspace, 'Gemfile.lock'))
      super
    end
  end
end
