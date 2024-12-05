#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'lib/ls_file'

def main
  options = parse_options
  target_directory = Pathname(ARGV[0] || '.')
  files = fetch_files(options, target_directory)
  if options[:long]
    show_files_by_long_format(files, target_directory, options)
  else
    show_files_by_default_format(files, target_directory, options)
  end
end

def parse_options
  options = { all: false, reverse: false, long: false }

  OptionParser.new do |opts|
    opts.on('-a') { options[:all] = true }
    opts.on('-r') { options[:reverse] = true }
    opts.on('-l') { options[:long] = true }
  end.parse!

  options
end

def fetch_files(options, target_directory)
  files = if options[:all]
            sort_all_files(Dir.foreach(target_directory), target_directory)
          else
            Dir.glob(target_directory.join('*')).sort
          end
  options[:reverse] ? files.reverse : files
end

def sort_all_files(files, target_directory)
  files = files.map { |file| target_directory.join(file) }
  files.sort_by do |file|
    if file == target_directory
      [0, file]
    elsif file == target_directory.parent
      [1, file]
    else
      [2, file.basename.sub(/^\./, '')]
    end
  end
end

def show_files_by_long_format(files, target_directory, options)
  max_length = fetch_file_max_length(files, target_directory, options)
  puts "total #{files.sum { |file| LsFile.new(file, target_directory, options).block_size }}"
  files.each do |file|
    ls_file = LsFile.new(file, target_directory, options)
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

def fetch_file_max_length(files, target_directory, options)
  ls_files = files.map { |file| LsFile.new(file, target_directory, options) }
  {
    hard_links: ls_files.map { |ls_file| ls_file.hard_links.to_s.length }.max,
    owner_name: ls_files.map { |ls_file| ls_file.owner_name.to_s.length }.max,
    owner_group_name: ls_files.map { |ls_file| ls_file.owner_group_name.to_s.length }.max,
    size: ls_files.map { |ls_file| ls_file.size_or_device_info.to_s.length }.max
  }
end

def show_files_by_default_format(files, target_directory, options)
  rows = (files.size.to_f / 3).ceil
  files_2d_array = Array.new(rows) { Array.new(3) }
  files.each_with_index { |file, index| files_2d_array[index % rows][index / rows] = file }
  max_lengths = fetch_file_name_max_lengths(files_2d_array, target_directory, options)
  files_2d_array.each do |files_array|
    formatted_row_files = files_array.compact.map.with_index do |file, index|
      LsFile.new(file, target_directory, options).name.ljust(max_lengths[index] + 2)
    end
    puts formatted_row_files.join
  end
end

def fetch_file_name_max_lengths(files_2d_array, target_directory, options)
  max_lengths = [0, 0, 0]

  files_2d_array.each do |files_array|
    files_array.compact.each_with_index do |file, index|
      file_name_length = LsFile.new(file, target_directory, options).name.length
      max_lengths[index] = [max_lengths[index], file_name_length].max
    end
  end

  max_lengths
end

main
