#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'lib/max_length'
require_relative 'lib/ls_file'

class Ls
  def initialize
    @options = parse_options
    @target_directory = Pathname(ARGV[0] || '.')
  end

  def show_files
    files = fetch_files(@options)
    max_length = @options[:long] ? MaxLength.new(files).file_information : MaxLength.new(files).file_name
    if @options[:long]
      show_files_by_long_format(files, max_length)
    else
      show_files_by_default_format(files, max_length)
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

  def show_files_by_long_format(files, max_length)
    puts "total #{files.sum { |file| LsFile.new(file, @target_directory, @options).block_size }}"
    files.each do |file|
      ls_file = LsFile.new(file, @target_directory, @options)
      puts "#{ls_file.type}" \
           "#{ls_file.permissions} " \
           "#{ls_file.hard_links.to_s.rjust(max_length[:nlink])} " \
           "#{ls_file.owner_name.to_s.rjust(max_length[:username])} " \
           "#{ls_file.owner_group_name.to_s.rjust(max_length[:groupname])} " \
           "#{ls_file.size_or_device_info.to_s.rjust(max_length[:size])} " \
           "#{ls_file.last_modified_time.to_s.rjust(5)} " \
           "#{ls_file.name}"
    end
  end

  def show_files_by_default_format(files, max_length)
    files_2d_array = Array.new(4) { Array.new(3) }
    files[0..11].each_with_index { |file, index| files_2d_array[index % 4][index / 4] = file }
    files_2d_array.each do |files_array|
      row_files = files_array.compact.map do |file|
        LsFile.new(file, @target_directory, @options).name.ljust(max_length + 1)
      end

      puts row_files.join
    end
  end
end

Ls.new.show_files
