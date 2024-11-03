#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'lib/option_parseable'
require_relative 'lib/file_fetchable'
require_relative 'lib/default_format'

class Ls
  include OptionParseable
  include FileFetchable

  def initialize
    @options = parse_options
    @files = fetch_files(@options)
  end

  def show_files
    files_2d_array = Array.new(4) { Array.new(3) }
    @files.each_with_index { |file, index| files_2d_array[index % 4][index / 4] = file }
    files_2d_array.each { |files_array| DefaultFormat.new(files_array).show_file }
  end
end

Ls.new.show_files
