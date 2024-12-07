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
            target_files = Dir.foreach(target_directory)
            sort_all_files(target_files, target_directory)
          else
            Dir.glob(target_directory.join('*')).sort
          end
  options[:reverse] ? files.reverse : files
end

def sort_all_files(target_files, target_directory)
  full_path_files = target_files.map { |target_file| target_directory.join(target_file) }
  full_path_files.sort_by do |full_path_file|
    if full_path_file == target_directory
      [0, full_path_file]
    elsif full_path_file == target_directory.parent
      [1, full_path_file]
    else
      [2, full_path_file.basename.sub(/^\./, '')]
    end
  end
end

def show_files_by_long_format(files, target_directory, options)
  max_length = fetch_file_max_length(files, target_directory, options)
  puts "total #{files.sum { |file| LsFile.new(file, target_directory, options).block_size }}"
  files.each do |file|
    ls_file = LsFile.new(file, target_directory, options)
    time_format = fetch_time_format(ls_file.file_stat)
    puts "#{ls_file.type}" \
         "#{ls_file.permission} " \
         "#{ls_file.hard_links.to_s.rjust(max_length[:hard_links])} " \
         "#{ls_file.owner_name.to_s.rjust(max_length[:owner_name])} " \
         "#{ls_file.owner_group_name.to_s.rjust(max_length[:owner_group_name])} " \
         "#{ls_file.size_or_device_info.to_s.rjust(max_length[:size])} " \
         "#{ls_file.last_modified_time.strftime(time_format).to_s.rjust(5)} " \
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

def fetch_time_format(file_stat)
  if Time.now.year == file_stat.mtime.year
    '%b %e %H:%M'
  else
    '%b %e  %Y'
  end
end

def show_files_by_default_format(files, target_directory, options)
  rows = (files.size.to_f / 3).ceil
  nested_files = Array.new(rows) { Array.new(3) }
  files.each_with_index { |file, index| nested_files[index % rows][index / rows] = file }
  max_lengths = fetch_file_name_max_lengths(nested_files, target_directory, options)
  nested_files.each do |row_files|
    formatted_row_files = row_files.compact.map.with_index do |file, index|
      LsFile.new(file, target_directory, options).name.ljust(max_lengths[index] + 2)
    end
    puts formatted_row_files.join
  end
end

def fetch_file_name_max_lengths(nested_files, target_directory, options)
  max_lengths = [0, 0, 0]

  nested_files.each do |row_files|
    row_files.compact.each_with_index do |file, index|
      file_name_length = LsFile.new(file, target_directory, options).name.length
      max_lengths[index] = [max_lengths[index], file_name_length].max
    end
  end

  max_lengths
end

main
