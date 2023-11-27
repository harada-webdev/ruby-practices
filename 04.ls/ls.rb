# frozen_string_literal: true

show_hidden = ARGV.include?('-a')

def fetch_file(show_hidden: false)
  Dir.glob('*', show_hidden ? File::FNM_DOTMATCH : 0).sort
end

def order_vertically(rows = 4, cols = 3, show_hidden: false)
  entries = fetch_file(show_hidden:)
  file_table = Array.new(rows) { Array.new(cols) }

  entries.each_with_index do |entry, index|
    col, row = index.divmod(rows)
    file_table[row][col] = entry
  end

  file_table
end

formatted_file_table = order_vertically(show_hidden:)
formatted_file_table.each do |file_row|
  puts file_row.map { |file_col| file_col.to_s.ljust(30) }.join
end


Dir.glob(show_hidden ? '{*,.*}' : '*').sort