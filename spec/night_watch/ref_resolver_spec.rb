require 'night_watch/ref_resolver'
require 'night_watch/utilities'
require 'fileutils'

module NightWatch
  describe RefResolver do
    include Utilities::ScriptRunner

    # The git tree used in these tests is as follows:
    #
    #     *   f56ccc4d5c21b7ec17d579c592f72b677672f580
    #     |\
    #     | * fc65e932c4c4e4fcd9524b19e2895be2c14e1815
    #     | * 15c6909f0eb047b450cf899dd99a163a025a205d
    #     * | f26f21accbd4f66abda38defbbb0560c852337f9
    #     |/
    #     * 78765b126537b8cee6399f0d6186b273d06aba2f
    #
    #

    before(:all) do
      test_tmp_dir = File.expand_path('../tmp', File.dirname(__FILE__))
      sh("rm -rf #{test_tmp_dir}")

      archive = File.expand_path('../fixtures/ref_resolver/repo_with_branches.tar.gz', File.dirname(__FILE__))
      @repo_dir = File.expand_path('ref_resolver/repo_with_branches', test_tmp_dir)
      FileUtils.mkdir_p(@repo_dir)
      Dir.chdir(@repo_dir) { sh("tar -xzf #{archive}") }
    end

    let(:ref_resolver) do
      RefResolver.new(@repo_dir)
    end

    describe '#find_baseline' do
      subject(:baseline) { ref_resolver.find_baseline(ref) }

      context 'when called with a commit with one parent' do
        let(:ref) { 'fc65e932c4c4e4fcd9524b19e2895be2c14e1815' }

        it 'returns the parent commit' do
          expect(baseline).to eq('15c6909f0eb047b450cf899dd99a163a025a205d')
        end
      end

      context 'when called with a commit with multiple parents' do
        let(:ref) { 'f56ccc4d5c21b7ec17d579c592f72b677672f580' }

        it 'returns the merge-base of parents' do
          expect(baseline).to eq('78765b126537b8cee6399f0d6186b273d06aba2f')
        end
      end

    end

  end
end
