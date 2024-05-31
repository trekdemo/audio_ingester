require 'tmpdir'

RSpec.describe 'Rakefile' do
  include_context 'rake'

  describe 'ensure_wav_ext' do
    it 'appends extentions to WAV files' do
      Dir.mktmpdir do |dir|
        FileUtils.cp fixture('image.png'), File.join(dir, 'image')
        FileUtils.cp fixture('sound.wav'), File.join(dir, 'sound')

        expect { rake['ensure_wav_ext'].invoke(dir) }
          .to(
            change { FileList["#{dir}/*"].pathmap('%f') }
              .from(%w[image sound])
              .to(%w[image sound.wav])
          )
      end
    end
  end

  describe 'extract_wav_metadata' do
    let(:input_dir) { Dir.mktmpdir }
    before do
      FileUtils.cp fixture('image.png'), File.join(input_dir, 'image')
      FileUtils.cp fixture('sound.wav'), File.join(input_dir, 'sound')
    end

    it 'extracts metadata into XML files' do
      expect { rake['extract_wav_metadata'].invoke(input_dir) }
        .to(
          change { FileList["#{input_dir}/*"].pathmap('%f') }
            .from(%w[image sound])
            .to(%w[image sound.wav sound.xml])
        )
    end

    it 'generates a valid metadata file' do
      rake['extract_wav_metadata'].invoke(input_dir)

      xsd = Nokogiri::XML::Schema(File.read('wav.xsd'))
      doc = Nokogiri::XML(File.read(File.join(input_dir, 'sound.xml')))

      expect(xsd.valid?(doc)).to be true
    end
  end
end
