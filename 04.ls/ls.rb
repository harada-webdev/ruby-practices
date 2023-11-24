# frozen_string_literal: true

def fetch_file
  Dir.glob('*')
     .sort
end

def order_vertically(rows = 4, cols = 3)
  entries = fetch_file
  file_table = Array.new(rows) { Array.new(cols) }

  entries.each_with_index do |entry, index|
    col, row = index.divmod(rows)
    file_table[row][col] = entry
  end

  file_table
end

formatted_file_table = order_vertically
formatted_file_table.each do |file_row|
  puts file_row.map { |file_col| file_col.to_s.ljust(30) }.join
end
