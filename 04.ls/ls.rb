# frozen_string_literal: true

def ruby_ls_maker
  Dir.entries('.')
     .reject { |entry| entry.start_with?('.') }
     .sort
end

def ls_vertical_order(rows = 4, cols = 3)
  ls_elements = ruby_ls_maker
  board = Array.new(rows) { Array.new(cols) }

  ls_elements.each_with_index do |element, index|
    col, row = index.divmod(rows)
    board[row][col] = element
  end

  board
end

ls_board = ls_vertical_order

ls_board.each do |document|
  puts document.map { |d| d.to_s.ljust(15) }.join
end
