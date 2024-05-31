require 'wav_file'

RSpec.describe WavFile do
  describe '.read_format' do
    let(:path) { fixture('sound.wav') }
    subject(:format) { described_class.read_format(path) }

    it 'returns with a rich object containing meta information' do
      expect(format.format_id).to eq(1)
      expect(format.channels).to eq(2)
      expect(format.sample_rate_hz).to eq(44_100)
      expect(format.bytes_per_sec).to eq(176_400)
      expect(format.block_size).to eq(4)
      expect(format.bit_per_sample).to eq(16)

      expect(format.format).to eq('PCM')
      # bit_rate = sample_rate_hz * channels * bit_per_sample
      expect(format.bit_rate).to eq(44_100 * 2 * 16)
    end

    context 'when the path points to a non-wav file' do
      let(:path) { fixture('image.png') }

      it 'raises error' do
        expect { format }.to raise_error(WavFile::WavFormatError)
      end
    end
  end

  describe '.wav_file?' do
    {
      fixture('sound.wav') => true,
      fixture('image.png') => false,
      fixture('text.txt') => false
    }.each_pair do |path, expected|
      context "when a path points to a #{path.extname} file" do
        subject { described_class.wav_file?(path) }
        it { is_expected.to eq(expected) }
      end
    end
  end

  describe WavFile::Format do
    describe '#to_xml' do
      let(:metadata) { WavFile.read_format(fixture('sound.wav')) }
      subject(:xml) { metadata.to_xml }

      it 'returns XML with WAV format information' do
        expect(xml).to eq(<<~XML)
          <?xml version="1.0" encoding="UTF-8"?>
          <track>
            <format>PCM</format>
            <channel_count>2</channel_count>
            <sampling_rate>44100</sampling_rate>
            <bit_depth>16</bit_depth>
            <byte_rate>176400</byte_rate>
            <bit_rate>1411200</bit_rate>
          </track>
        XML
      end

      it 'generates a valid metadata file' do
        xsd = Nokogiri::XML::Schema(File.read('wav.xsd'))
        doc = Nokogiri::XML(xml)

        expect(xsd.valid?(doc)).to be true
      end
    end
  end
end
