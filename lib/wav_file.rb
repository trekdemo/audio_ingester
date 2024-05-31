# frozen_string_literal: true

require 'nokogiri'

# WavFile gathers information about WAV files.
module WavFile
  WavFormatError = Class.new(StandardError)

  # Parses the file header and returns data format information
  #
  # @param [String] path file path to a WAV file.
  # @return WavFile::Format
  # @raise [WavFile::WavFormatError] Raised when the file header is invalid.
  #
  def self.read_format(path)
    # The header of a WAV (RIFF) file is 44 bytes long and has the following format:
    # Source: https://en.wikipedia.org/wiki/WAV#WAV_file_header
    #
    # Master RIFF chunk
    # -----------------
    # FileTypeBlocID  (4 bytes) : Identifier « RIFF »  (0x52, 0x49, 0x46, 0x46)
    # FileSize        (4 bytes) : Overall file size minus 8 bytes
    # FileFormatID    (4 bytes) : Format = « WAVE »  (0x57, 0x41, 0x56, 0x45)
    #
    # Information about the data format block
    # --------------------------------------
    # FormatBlocID    (4 bytes) : Identifier « fmt␣ »  (0x66, 0x6D, 0x74, 0x20)
    # BlocSize        (4 bytes) : Chunk size minus 8 bytes, which is 16 bytes here  (0x10)
    #
    # Chunk describing the data format
    # --------------------------------
    # AudioFormat     (2 bytes) : Audio format (1: PCM integer, 3: IIEE float)
    # NbrChannels     (2 bytes) : Number of channels
    # Frequence       (4 bytes) : Sample rate (in hertz)
    # BytePerSec      (4 bytes) : Number of bytes to read per second (Frequence * BytePerBloc).
    # BytePerBloc     (2 bytes) : Number of bytes per block (NbrChannels * BitsPerSample / 8).
    # BitsPerSample   (2 bytes) : Number of bits per sample
    File.open(path, 'rb') do |file|
      # Master RIFF chunk
      ftype   = file.read(4) and assert(ftype, 'RIFF')
      _fsize  = file.read(4)
      fformat = file.read(4) and assert(fformat, 'WAVE')

      # Chunk describing the data format
      block_id = file.read(4) and assert(block_id, 'fmt ')
      block_size = file.read(4).unpack1('V').to_i
      format_data = file.read(block_size)

      Format.new(
        format_id: format_data.slice(0, 2).unpack1('c'),
        channels: format_data.slice(2, 2).unpack1('c'),
        sample_rate_hz: format_data.slice(4, 4).unpack('V').join.to_i,
        bytes_per_sec: format_data.slice(8, 4).unpack('V').join.to_i,
        block_size: format_data.slice(12, 2).unpack1('c'),
        bit_per_sample: format_data.slice(14, 2).unpack1('c')
      )
    end
  end

  # Decides if the path points to a WAV file
  #
  # @param [String] path file path to a WAV file.
  # @return Boolean
  #
  def self.wav_file?(path)
    !!read_format(path)
  rescue WavFormatError
    false
  end

  # @private
  def self.assert(value, expected)
    raise WavFormatError if value != expected
  end
  private_class_method :assert

  # Format contains information about the data format of a WAV file
  Format = Data.define(:format_id, :channels, :sample_rate_hz, :bytes_per_sec, :block_size, :bit_per_sample) do
    def format
      format_id == 1 ? 'PCM' : 'Compressed'
    end

    def bit_rate
      sample_rate_hz * channels * bit_per_sample
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.track do
          xml.format format
          xml.channel_count channels
          xml.sampling_rate sample_rate_hz
          xml.bit_depth bit_per_sample
          xml.byte_rate bytes_per_sec
          xml.bit_rate bit_rate
        end
      end

      builder.to_xml
    end
  end
end
