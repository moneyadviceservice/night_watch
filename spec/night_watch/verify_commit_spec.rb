require 'night_watch'
require 'fileutils'

module NightWatch
  describe VerifyCommit do
    include Utilities::ScriptRunner

    before(:all) do
      test_tmp_dir = File.expand_path('../tmp', File.dirname(__FILE__))
      sh("rm -rf #{test_tmp_dir}")

      @workspace_dir = File.expand_path('workspace', test_tmp_dir)
      FileUtils.mkdir_p(@workspace_dir)

      origins = []
      origins_dir = File.expand_path('origins', test_tmp_dir)
      FileUtils.mkdir_p(origins_dir)
      Dir[File.expand_path('../fixtures/*.tar.gz', File.dirname(__FILE__))].each do |archive|
        repo_dir = File.join(origins_dir, File.basename(archive, '.tar.gz'))
        FileUtils.mkdir_p(repo_dir)
        Dir.chdir(repo_dir) { sh("tar -xzf #{archive}") }
        origins << repo_dir
      end

      @repo_manager = Utilities::GitRepositoriesManager.new(File.expand_path('projects', @workspace_dir), origins)
      @repo_manager.create(true)
    end

    let(:verify_commit) do
      VerifyCommit.new(
        'repo_to_validate',
        'REF_TO_TEST',
        @repo_manager,
        @workspace_dir,
      )
    end

    describe '#find_broken_dependants' do
      it 'can identify rails applications that have been broken by a commit' do
        broken_dependants = verify_commit.find_broken_dependants(
          rails_apps: {
            'app_that_breaks' => ['/'],
            'app_that_doesnt_break' => ['/styleguide/all']
          }
        )

        expect(broken_dependants).to include('app_that_breaks')
        expect(broken_dependants).not_to include('app_that_doesnt_break')
      end

      it 'can identify rails engines that have been broken by a commit' do
        broken_dependants = verify_commit.find_broken_dependants(
          rails_engines: {
            'engine_that_breaks' => ['/styleguide'],
            'engine_that_doesnt_break' => ['/styleguide/all']
          }
        )

        expect(broken_dependants).to include('engine_that_breaks')
        expect(broken_dependants).not_to include('engine_that_doesnt_break')
      end
    end

  end
end
