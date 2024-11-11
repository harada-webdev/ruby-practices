#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'lib/default_format'
require_relative 'lib/long_format'

class Ls
  def initialize
    @options = parse_options
    @target_directory = Pathname(ARGV[0] || '.')
  end

  def show_files
    files = fetch_files(@options)
    if @options[:long]
      puts "total #{files.sum { |file| File::Stat.new(file).blocks / 2 }}"
      files.each { |file| LongFormat.new(file, @target_directory).show_file }
    else
      files_2d_array = Array.new(4) { Array.new(3) }
      files.each_with_index { |file, index| files_2d_array[index % 4][index / 4] = file }
      files_2d_array.each { |files_array| DefaultFormat.new(files_array, @target_directory).show_file }
    end
  end

  private

  def parse_options
    options = { all: false, reverse: false, long: false }

    OptionParser.new do |opts|
      opts.on('-a') { options[:all] = true }
      opts.on('-r') { options[:reverse] = true }
      opts.on('-l') { options[:long] = true }
    end.parse!

    options
  end

  def fetch_files(options)
    files = if options[:all]
              sort_all_files(Dir.foreach(@target_directory))
            else
              Dir.glob(@target_directory.join('*')).sort
            end
    options[:reverse] ? files.reverse : files
  end

  def sort_all_files(files)
    files = files.map { |file| @target_directory.join(file) }
    files.sort_by do |file|
      if file == @target_directory
        [0, file]
      elsif file == @target_directory.parent
        [1, file]
      else
        [2, file.basename.sub(/^\./, '')]
      end
    end
  end
end

Ls.new.show_files
