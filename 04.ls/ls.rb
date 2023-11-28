# frozen_string_literal: true

show_reversed = ARGV.include?('-r')

def fetch_file(show_reversed: false)
  sorted_files = Dir.glob('*').sort
  show_reversed ? sorted_files.reverse : sorted_files
end

def order_vertically(rows = 4, cols = 3, show_reversed: false)
  entries = fetch_file(show_reversed:)
  file_table = Array.new(rows) { Array.new(cols) }

  entries.each_with_index do |entry, index|
    col, row = index.divmod(rows)
    file_table[row][col] = entry
  end

  file_table
end

formatted_file_table = order_vertically(show_reversed:)
formatted_file_table.each do |file_row|
  puts file_row.map { |file_col| file_col.to_s.ljust(30) }.join
end
