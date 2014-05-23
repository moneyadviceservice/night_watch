require 'night_watch/repo_to_validate'

module NightWatch
  class BowerRepoToValidate < RepoToValidate
    def setup
      in_workspace { sh("bower link") }
    end

    def link_to(app)
      app.in_workspace { sh("bower link #{name}") }
    end
  end
end
