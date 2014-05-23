require 'night_watch/rails_app'

module NightWatch
  class RailsEngine < RailsApp

  protected

    def rails_root
      File.join(super, 'spec', 'dummy')
    end

  end
end
