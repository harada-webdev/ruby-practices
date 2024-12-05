#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'lib/ls_file'

class Ls
  def initialize
    @options = parse_options
    @target_directory = Pathname(ARGV[0] || '.')
  end

  def show_files
    files = fetch_files(@options)
    if @options[:long]
      show_files_by_long_format(files)
    else
      show_files_by_default_format(files)
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

  def show_files_by_long_format(files)
    max_length = fetch_file_max_length(files)
    puts "total #{files.sum { |file| LsFile.new(file, @target_directory, @options).block_size }}"
    files.each do |file|
      ls_file = LsFile.new(file, @target_directory, @options)
      puts "#{ls_file.type}" \
           "#{ls_file.permissions} " \
           "#{ls_file.hard_links.to_s.rjust(max_length[:hard_links])} " \
           "#{ls_file.owner_name.to_s.rjust(max_length[:owner_name])} " \
           "#{ls_file.owner_group_name.to_s.rjust(max_length[:owner_group_name])} " \
           "#{ls_file.size_or_device_info.to_s.rjust(max_length[:size])} " \
           "#{ls_file.last_modified_time.to_s.rjust(5)} " \
           "#{ls_file.name}"
    end
  end

  def fetch_file_max_length(files)
    ls_files = files.map { |file| LsFile.new(file, @target_directory, @options) }
    {
      hard_links: ls_files.map { |ls_file| ls_file.hard_links.to_s.length }.max,
      owner_name: ls_files.map { |ls_file| ls_file.owner_name.to_s.length }.max,
      owner_group_name: ls_files.map { |ls_file| ls_file.owner_group_name.to_s.length }.max,
      size: ls_files.map { |ls_file| ls_file.size_or_device_info.to_s.length }.max
    }
  end

  def show_files_by_default_format(files)
    max_length = fetch_file_name_max_length(files)
    files_2d_array = Array.new(4) { Array.new(3) }
    files[0..11].each_with_index { |file, index| files_2d_array[index % 4][index / 4] = file }
    files_2d_array.each do |files_array|
      row_files = files_array.compact.map do |file|
        LsFile.new(file, @target_directory, @options).name.ljust(max_length + 1)
      end

      puts row_files.join
    end
  end

  def fetch_file_name_max_length(files)
    files[0, 11].map do |file|
      LsFile.new(file, @target_directory, @options).name.to_s.length
    end.max + 1
  end
end

Ls.new.show_files
