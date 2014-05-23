require 'night_watch/repo_to_validate'
require 'json'

module NightWatch
  class BowerRepoToValidate < RepoToValidate
    def setup
      in_workspace { sh("bower link") }
    end

    def link_to(app)
      app.in_workspace { sh("bower link #{bower_module_name}") }
    end

    def bower_module_name
      in_workspace do
        JSON.parse(File.read("bower.json")).fetch('name') { name }
      end
    end
  end
end
