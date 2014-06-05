require 'night_watch/ref_range'
require 'rspec/its'

module NightWatch
  describe RefRange do
    context 'instantiated with ref_from and ref_to' do
      subject { RefRange.new('ref_from', 'ref_to') }

      its(:from) { should eq('ref_from') }
      its(:to) { should eq('ref_to') }
      it { should be_frozen }
    end

    describe '::parse' do
      it 'returns a RefRange' do
        expect(RefRange.parse('foo')).to be_a(RefRange)
      end

      it 'can handle ranges in the format REF_FROM..REF_TO' do
        ref_range = RefRange.parse('REF_FROM..REF_TO')

        expect(ref_range.from).to eq('REF_FROM')
        expect(ref_range.to).to eq('REF_TO')
      end

      it 'can handle single refs' do
        ref_range = RefRange.parse('REF_SINGLE')

        expect(ref_range.from).to eq('REF_SINGLE')
        expect(ref_range.to).to eq('REF_SINGLE')
      end
    end
  end
end
