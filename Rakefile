# frozen_string_literal: true

require 'rake'
require_relative 'lib/wav_file'

desc 'Appends `.wav` extension to extension-less WAV files'
task :ensure_wav_ext, :input_dir do |_t, args|
  input_dir = args.fetch(:input_dir) { abort 'Failed; must specify input_dir argument.' }
  files_without_ext = Rake::FileList.new("#{input_dir}/*").exclude(/\.\w*$/)

  files_without_ext.each do |path|
    next unless WavFile.wav_file?(path)

    mv path, path.ext('wav'), verbose: false
  end
end
