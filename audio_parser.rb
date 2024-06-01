#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rake'
Rake.load_rakefile('Rakefile')

source_directory = ARGV[0]
Rake::Task['wav:extract_metadata'].invoke(source_directory)
