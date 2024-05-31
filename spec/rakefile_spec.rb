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
end
