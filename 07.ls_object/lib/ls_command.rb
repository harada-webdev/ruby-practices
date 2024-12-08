# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'ls_file'

class LsCommand
  COLS = 3

  def show_files
    options = parse_options
    target_directory = Pathname(ARGV[0] || '.')
    files = fetch_files(options, target_directory)
    ls_files = files.map { |file| LsFile.new(file, target_directory, options) }
    if options[:long]
      show_files_by_long_format(ls_files)
    else
      show_files_by_default_format(ls_files)
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

  def show_files_by_long_format(ls_files)
    max_length = bring_file_max_length(ls_files)
    puts "total #{ls_files.sum(&:block_size)}"
    ls_files.each do |ls_file|
      time_format = bring_time_format(ls_file.file_stat)
      puts [
        ls_file.mode,
        ls_file.hard_links.to_s.rjust(max_length[:hard_links]),
        ls_file.owner_name.to_s.rjust(max_length[:owner_name]),
        ls_file.owner_group_name.to_s.rjust(max_length[:owner_group_name]),
        ls_file.size_or_device_info.to_s.rjust(max_length[:size]),
        ls_file.last_modified_time.strftime(time_format),
        ls_file.name
      ].join(' ')
    end
  end

  def bring_file_max_length(ls_files)
    {
      hard_links: ls_files.map { |ls_file| ls_file.hard_links.to_s.length }.max,
      owner_name: ls_files.map { |ls_file| ls_file.owner_name.to_s.length }.max,
      owner_group_name: ls_files.map { |ls_file| ls_file.owner_group_name.to_s.length }.max,
      size: ls_files.map { |ls_file| ls_file.size_or_device_info.to_s.length }.max
    }
  end

  def bring_time_format(file_stat)
    if Time.now.year == file_stat.mtime.year
      '%b %e %H:%M'
    else
      '%b %e  %Y'
    end
  end

  def show_files_by_default_format(ls_files)
    rows = (ls_files.size.to_f / COLS).ceil
    nested_files = Array.new(rows) { Array.new(COLS) }
    ls_files.each_with_index { |ls_file, index| nested_files[index % rows][index / rows] = ls_file }
    max_lengths = bring_file_name_max_lengths(nested_files)
    nested_files.each do |row_files|
      formatted_row_files = row_files.compact.map.with_index do |file, index|
        file.name.ljust(max_lengths[index] + 2)
      end
      puts formatted_row_files.join
    end
  end

  def bring_file_name_max_lengths(nested_files)
    max_lengths = [0] * COLS

    nested_files.each do |row_files|
      row_files.compact.each_with_index do |file, index|
        file_name_length = file.name.length
        max_lengths[index] = [max_lengths[index], file_name_length].max
      end
    end

    max_lengths
  end
end
