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
    basenames = Dir.foreach(target_directory)
    ls_files = basenames.map { |basename| LsFile.new(basename, target_directory) }
    filtered_ls_files = options[:all] ? ls_files : ls_files.reject(&:hidden?)
    options[:reverse] ? filtered_ls_files.sort.reverse : filtered_ls_files.sort
  end

  def show_files_in_long_format(ls_files)
    puts "total #{ls_files.sum(&:block_size)}"
    max_lengths = find_max_lengths_by_props(ls_files)
    ls_files.each do |ls_file|
      cols = []
      cols << ls_file.mode
      cols << ls_file.hard_links.to_s.rjust(max_lengths[:hard_links])
      cols << ls_file.owner_name.to_s.ljust(max_lengths[:owner_name])
      cols << ls_file.owner_group_name.to_s.ljust(max_lengths[:owner_group_name])
      cols << ls_file.size_or_device_info.to_s.rjust(max_lengths[:size])
      cols << format_last_modified_time(ls_file)
      cols << format_name(ls_file)
      puts cols.join(' ')
    end
  end

  def find_max_lengths_by_props(ls_files)
    {
      hard_links: ls_files.map { |ls_file| ls_file.hard_links.to_s.length }.max,
      owner_name: ls_files.map { |ls_file| ls_file.owner_name.to_s.length }.max,
      owner_group_name: ls_files.map { |ls_file| ls_file.owner_group_name.to_s.length }.max,
      size: ls_files.map { |ls_file| ls_file.size_or_device_info.to_s.length }.max
    }
  end

  def format_last_modified_time(ls_file)
    format = if ls_file.current_year?
               '%b %e %H:%M'
             else
               '%b %e  %Y'
             end
    ls_file.last_modified_time.strftime(format)
  end

  def format_name(ls_file)
    if ls_file.symlink?
      "#{ls_file.name} -> #{ls_file.referenced_file}"
    else
      ls_file.name
    end
  end

  def show_files_in_default_format(ls_files)
    rows = (ls_files.size.to_f / COLS).ceil
    nested_ls_files = Array.new(rows) { Array.new(COLS) }
    ls_files.each_with_index { |ls_file, index| nested_ls_files[index % rows][index / rows] = ls_file }
    max_lengths = find_max_lengths_by_column(nested_ls_files)
    nested_ls_files.each do |row_ls_files|
      formatted_row_ls_files = row_ls_files.compact.map.with_index do |ls_file, index|
        ls_file.name.ljust(max_lengths[index] + 2)
      end
      puts formatted_row_ls_files.join
    end
  end

  def find_max_lengths_by_column(nested_ls_files)
    nested_ls_files.each_with_object(Array.new(COLS, 0)) do |row_ls_files, max_lengths|
      row_ls_files.compact.each_with_index do |ls_file, index|
        ls_file_name_length = ls_file.name.length
        max_lengths[index] = [max_lengths[index], ls_file_name_length].max
      end
    end
  end
end
