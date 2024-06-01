require 'tmpdir'

RSpec.describe 'Rakefile' do
  include_context 'rake'

  describe 'wav:ensure_ext' do
    it 'appends extentions to WAV files' do
      Dir.mktmpdir do |dir|
        FileUtils.cp fixture('image.png'), File.join(dir, 'image')
        FileUtils.cp fixture('sound.wav'), File.join(dir, 'sound')

        expect { task.invoke(dir) }
          .to(
            change { FileList["#{dir}/*"].pathmap('%f') }
              .from(%w[image sound])
              .to(%w[image sound.wav])
          )
      end
    end
  end

  describe 'wav:extract_metadata' do
    let(:input_dir) { Pathname(Dir.mktmpdir('input_dir')) }

    before do
      FileUtils.rm_rf "#{__dir__}/../output/"
      FileUtils.cp fixture('image.png'), input_dir.join('image')
      FileUtils.cp fixture('sound.wav'), input_dir.join('sound')
    end

    it 'extracts metadata into XML files' do
      expect { task.invoke(input_dir) }
        .to(
          change { FileList["#{input_dir}/*"].pathmap('%f') }
            .from(%w[image sound])
            .to(%w[image sound.wav])
          .and(
            change { FileList['./output/*/*'].pathmap('%f') }
            .from(%w[])
            .to(%w[sound.xml])
          )
        )
    end

    it 'generates a valid metadata files' do
      task.invoke(input_dir)

      xsd = Nokogiri::XML::Schema(File.read('wav.xsd'))
      Dir['output/*/*.xml'].each do |xml_path|
        doc = Nokogiri::XML(File.read(xml_path))
        expect(xsd.valid?(doc)).to be true
      end
    end
  end
end
