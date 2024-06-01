# Audio File Parser

Extract file-format information from WAV files.

## Getting started

To install the dependencies run `bundle install`.

Run the tests using `bin/rspec`.

Execute the script by either running the entrypoint script or the rake task directly.

```sh
ruby audio_parser.rb <input_dir>
# or
rake wav:extract_metadata[<input_dir>]
```

*Tip: If you're using zsh, you need to escape the `\[` `\]` brackets.*

Then find the output files in the `output/<timestamp>` directory.

## About the ideas behind the implementation

As soon as I understood that the task requires generating files based on source files, I thought of Rake and its [file tasks](https://ruby.github.io/rake/doc/rakefile_rdoc.html#label-File+Tasks) and [rules](https://ruby.github.io/rake/doc/rakefile_rdoc.html#label-Rules). They help to define workflows that generate output based on input files.

Rake makes working with files a bliss thanks to its integration with [`FileUtils`](https://docs.ruby-lang.org/en/master/FileUtils.html) and its built-in [`Rake::FileList`](https://www.rubydoc.info/gems/rake/FileUtils).

### Rake tasks

To implement the requirements, I divided the workflow into a two Rake tasks:

1. `rake wav:ensure_ext[input_dir]`\
   Ensures that all *WAV* files have the `.wav` extension.
   I noticed that `input_files/sample-file-2` is a *WAV* file, but without the `.wav` extension.
   It seemed easier to work with these files if every file had the correct extension, so I created a task () to append the extension when needed.
1. `rake wav:extract_metadata[input_dir]`\
   Extracts the file format information from each file and move them to the output folder.
   This task has the previous as a [*prerequisite*](https://ruby.github.io/rake/doc/rakefile_rdoc.html#label-Tasks+with+Prerequisites), so it will process wav files even if they did not have the `.wav` extension previously.
   The task uses the `WavFile` module, to extract the file format information and to generate an XML string.
   Once the XML string is returned, the task writes it into the output file and then moves it to the output directory.

### `WavFile` module

Since the current requirements are relatively simple, I placed all *WAV* parsing and reporting related logic into a single module.

#### `WavFile.read_format`

Parsing the file header for file format information is implemented in the `WavFile.read_format`.
I deliberately kept parsing each chunk in a single function, to tell a coherent story how the WAV-file header is structured.
To provide a *rich* return value, `WavFile::Format`, I used the [`Data`](https://docs.ruby-lang.org/en/3.2/Data.html) class, introduced in Ruby 3.2.

#### `WavFile::Format#to_xml`

To keep the implementation simple, `WavFile::Format` knows how to represent itself as XML, through the `#to_xml` function. This should feel familiar to how models work in vanilla Rails applications. If multiple formats are needed, this logic can be moved/extracted into context-aware serializers or presenters.

To generate XML, I used Nokogiri, for its simple builder API and the XSD validation capabilities.

______________________________________________________________________

## Instructions:

- Write a ruby script that accepts a directory as an input. Eg. `ruby audio_parser.rb <input_dir>`

  - This script will extract metadata information from Wav files.
  - Any non Wav files will be ignored by the script.
  - The script should be able to generate applicable output(s) even if some files are ignored.

- Extract the following metadata information from the Wav files.

  - **IMPORTANT!** You must not use any existing third party **executable** to extract the data like mediainfo or ffprobe.
  - You are allowed to use any ruby library to help you read and interpret the bytes from the input files.

| Attribute     | Type    | Sample Value                   | Mediainfo equivalend field name |
| ------------- | ------- | ------------------------------ | ------------------------------- |
| Format        | String  | 1 = "PCM",                     | Audio format                    |
|               |         | any other value = "Compressed" |                                 |
| Channel Count | Integer | 2                              | Channel(s)                      |
| Sampling Rate | Integer | 88200 or 88.2 kHz              | Sampling Rate                   |
| Byte Rate     | Integer | 150000                         | None                            |
| Bit Depth     | Integer | 32                             | Bit depth                       |
| Bit Rate      | Integer | 2822400                        | Bit rate                        |

Notes:

- Bit Rate is calculated using the formula: Sampling Rate * Channel Count * Bit Depth
- Format is either 1 or other integer number but for this exercise, we will map it to "PCM" if you detected 1 or "Compressed" for other integer values.

## Output

- Generate an output folder and the current timestamp to store your output files.
  - Eg. `output/1708976890/sample-file-3.xml`
- Write the output in an xml file using the provided wav.xsd file as your guide.
  - Each valid file should have a corresponding xml using the same file name. E.g. `sample-file-3.xml`
  - You are allowed to use any existing ruby xml libraries to make xml building faster.
- We will run your code over the given input_files and check the generated output xmls.

## Bonus Points

- Handling Errors
- Unit Test

## Hint

- You would have to do a quick research on the structure of a Wav file. (Easily found information)
- You can also check Resource Interchange File Format (RIFF).
- You don't need to parse the whole file. You just need to parse where the metadata info is stored.
- You can use mediainfo to validate your output manually.

Enjoy this Music Related Exercise :)

