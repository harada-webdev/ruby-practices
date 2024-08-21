# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  options = parse_options
  sorted_files = fetch_file(show_hidden: options[:show_hidden], show_reversed: options[:show_reversed])
  if options[:show_detail]
    exposit_files(sorted_files)
  else
    formatted_file_table = order_vertically(sorted_files)
    formatted_file_table.each do |file_row|
      puts file_row.map { |file_col| file_col.to_s.ljust(30) }.join
    end
  end
end

def parse_options
  options = { show_hidden: false, show_reversed: false, show_detail: false }

  OptionParser.new do |opts|
    opts.on('-a') { options[:show_hidden] = true }
    opts.on('-r') { options[:show_reversed] = true }
    opts.on('-l') { options[:show_detail] = true }
  end.parse!

  options
end

def fetch_file(show_hidden: false, show_reversed: false)
  entries = Dir.glob('*', show_hidden ? File::FNM_DOTMATCH : 0).sort
  entries = entries.reverse if show_reversed
  entries
end

def order_vertically(files, rows = 4, cols = 3)
  file_table = Array.new(rows) { Array.new(cols) }

  files.each_with_index do |entry, index|
    col, row = index.divmod(rows)
    file_table[row][col] = entry
  end

  file_table
end

def exposit_files(files)
  puts "total #{calculate_total_block_size(files)}"
  display_file_mode(files)
end

def calculate_total_block_size(files)
  files.sum do |file|
    file_stat = File::Stat.new(file)
    required_block_number = (file_stat.size / file_stat.blksize.to_f).ceil
    required_block_number * file_stat.blksize / 1024.0.ceil
  end
end

def display_file_mode(files)
  files.each do |file|
    file_stat = File::Stat.new(file)
    file_mode = change_mode_appearance(file_stat.mode)
    file_mode = File.directory?(file) ? "d#{file_mode}" : "-#{file_mode}"
    display_file_detail(file, file_stat, file_mode)
  end
end

def change_mode_appearance(mode_number)
  string_expression = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx']
  mode_number.to_s(8)[-3..].chars.map { |number| string_expression[number.to_i] }.join
end

def display_file_detail(file, file_stat, file_mode)
  puts ''\
     "#{file_mode} "\
     "#{file_stat.nlink} "\
     "#{Etc.getpwuid(file_stat.uid).name} "\
     "#{Etc.getgrgid(file_stat.gid).name} "\
     "#{file_stat.size.to_s.rjust(4)} "\
     "#{file_stat.mtime.strftime('%b %_d %H:%M')} "\
     "#{file}"
end

main
