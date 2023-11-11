# frozen_string_literal: true

def fetch_file
  Dir.glob('[^.]*')
     .sort
end

def order_vertically(rows = 4, cols = 3)
  entries = fetch_file
  board = Array.new(rows) { Array.new(cols) }

  entries.each_with_index do |entry, index|
    col, row = index.divmod(rows)
    board[row][col] = entry
  end

  board
end

file_list_board = order_vertically
file_list_board.each do |file_row|
  puts file_row.map { |file_col| file_col.to_s.ljust(30) }.join
end
