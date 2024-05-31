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
end
