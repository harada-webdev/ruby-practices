# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'ls_file'

class LsCommand
  COLS = 3

  def show_files
    options = parse_options
    ls_files = build_ls_files(options)
    if options[:long]
      show_files_in_long_format(ls_files)
    else
      show_files_in_default_format(ls_files)
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

  def build_ls_files(options)
    target_directory = Pathname(ARGV[0] || '.')
    files = Dir.foreach(target_directory)
    ls_files = files.map { |file| LsFile.new(file, target_directory, options) }
    filtered_ls_files = options[:all] ? ls_files : ls_files.reject(&:hidden?)
    options[:reverse] ? filtered_ls_files.sort.reverse : filtered_ls_files.sort
  end

  def show_files_in_long_format(ls_files)
    max_length = find_file_max_length(ls_files)
    puts "total #{ls_files.sum(&:block_size)}"
    ls_files.each do |ls_file|
      time_format = bring_time_format(ls_file.last_modified_time)
      ls_file_properties = []
      ls_file_properties << ls_file.mode
      ls_file_properties << ls_file.hard_links.to_s.rjust(max_length[:hard_links])
      ls_file_properties << ls_file.owner_name.to_s.rjust(max_length[:owner_name])
      ls_file_properties << ls_file.owner_group_name.to_s.rjust(max_length[:owner_group_name])
      ls_file_properties << ls_file.size_or_device_info.to_s.rjust(max_length[:size])
      ls_file_properties << ls_file.last_modified_time.strftime(time_format)
      ls_file_properties << ls_file.name
      puts ls_file_properties.join(' ')
    end
  end

  def find_file_max_length(ls_files)
    {
      hard_links: ls_files.map { |ls_file| ls_file.hard_links.to_s.length }.max,
      owner_name: ls_files.map { |ls_file| ls_file.owner_name.to_s.length }.max,
      owner_group_name: ls_files.map { |ls_file| ls_file.owner_group_name.to_s.length }.max,
      size: ls_files.map { |ls_file| ls_file.size_or_device_info.to_s.length }.max
    }
  end

  def bring_time_format(last_modified_time)
    if Time.now.year == last_modified_time.year
      '%b %e %H:%M'
    else
      '%b %e  %Y'
    end
  end

  def show_files_in_default_format(ls_files)
    rows = (ls_files.size.to_f / COLS).ceil
    nested_files = Array.new(rows) { Array.new(COLS) }
    ls_files.each_with_index { |ls_file, index| nested_files[index % rows][index / rows] = ls_file }
    max_lengths = find_file_name_max_lengths(nested_files)
    nested_files.each do |row_files|
      formatted_row_files = row_files.compact.map.with_index do |file, index|
        file.name.ljust(max_lengths[index] + 2)
      end
      puts formatted_row_files.join
    end
  end

  def find_file_name_max_lengths(nested_files)
    max_lengths = Array.new(COLS, 0)

    nested_files.each do |row_files|
      row_files.compact.each_with_index do |file, index|
        file_name_length = file.name.length
        max_lengths[index] = [max_lengths[index], file_name_length].max
      end
    end

    max_lengths
  end
end
