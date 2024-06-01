# frozen_string_literal: true

require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'
require_relative 'lib/wav_file'

CLOBBER.add('output/')

namespace :wav do
  desc 'Appends `.wav` extension to extension-less WAV files'
  task :ensure_ext, :input_dir do |_t, args|
    input_dir = args.fetch(:input_dir) { abort 'Failed; must specify input_dir argument.' }
    files_without_ext = Rake::FileList.new("#{input_dir}/*").exclude(/\.\w*$/)

    files_without_ext.each do |path|
      next unless WavFile.wav_file?(path)

      mv path, path.ext('wav'), verbose: false
    end
  end

  desc 'Extracts the metadata from .wav files in the input directory'
  task :extract_metadata, [:input_dir] => [:ensure_ext] do |_t, args|
    input_dir = args.fetch(:input_dir) { abort 'Failed; must specify input_dir.' }
    wav_files = Rake::FileList.new("#{input_dir}/*.wav")
    xml_files = wav_files.ext('xml')

    # Extract metadata concurrently from each file.
    # The rule at the bottom will match each individual output file.
    multitask extract_metadata_to: xml_files
    Rake::Task['extract_metadata_to'].invoke

    # Move the metadata files into the timestamped output directory
    output_dir = "output/#{Time.now.to_i}/"
    mkdir_p output_dir, verbose: false
    mv xml_files, output_dir, verbose: false
  end

  # Rule to generate an XML from a WAV file
  rule '.xml' => '.wav' do |t|
    puts "Processing #{t.source}..."
    File.open(t.name, 'w') do |f|
      f.write WavFile.read_format(t.source).to_xml
    end
  end
end

RSpec::Core::RakeTask.new(:spec)
task default: :spec
