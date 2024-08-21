# frozen_string_literal: true

def main
  sum = { first: 0, second: 0, third: 0 }
  selected_options = ''
  parse_command_line_arguments(sum, selected_options)
end

def parse_command_line_arguments(sum, selected_options)
  if ARGV[0]&.match?(/-/)
    selected_options = ARGV[0]
    files = ARGV[1..]
  elsif ARGV[0]
    files = ARGV
  else
    files = []
  end
  judge_whether_stdin_or_not(files, sum, selected_options)
end

def judge_whether_stdin_or_not(files, sum, selected_options)
  stdin_data = $stdin.read if files.empty?
  if stdin_data
    put_counted_data_in_array(stdin_data, selected_options, sum, nil)
  else
    files.each do |file|
      content = File.read(file)
      put_counted_data_in_array(content, selected_options, sum, file)
    end
    display_total_data(sum) if files && files.count > 1
  end
end

def put_counted_data_in_array(data, selected_options, sum, file)
  counts = { words: data.split.size, lines: data.split("\n").size, bytes: data.size }

  array = []
  option_hash = { /l/ => counts[:lines], /w/ => counts[:words], /c/ => counts[:bytes] }
  option_hash.each do |option, counted_data_by_option|
    array << counted_data_by_option if selected_options.match?(option)
  end

  judge_whether_option_or_not(selected_options, array, counts, file, sum)
end

def judge_whether_option_or_not(selected_options, array, counts, file, sum)
  if selected_options.empty?
    display_no_option_format(counts, file)
    update_sum_from_counts(sum, counts)
  else
    display_format_with_options(array, file)
    update_sum_from_array(sum, array)
  end
end

def display_no_option_format(counts, file)
  puts "#{counts[:lines].to_s.rjust(5)} " \
       "#{counts[:words].to_s.rjust(5)} " \
       "#{counts[:bytes].to_s.rjust(5)} " \
       "#{file}"
end

def update_sum_from_counts(sum, counts)
  sum.update(
    first: sum[:first] + counts[:lines],
    second: sum[:second] + counts[:words],
    third: sum[:third] + counts[:bytes]
  )
end

def display_format_with_options(array, file)
  puts "#{array.map(&:to_s).map { |s| s.rjust(5) }.join(' ')} " \
       "#{file}"
end

def update_sum_from_array(sum, array)
  sum.update(
    first: sum[:first] + array[0].to_i,
    second: sum[:second] + array[1].to_i,
    third: sum[:third] + array[2].to_i
  )
end

def display_total_data(sum)
  sum_data_array = []
  sum.each_with_index do |(_key, value), index|
    break if ARGV[0].match?(/-/) && ARGV[0].chars.count - 1 <= index

    sum_data_array << value
  end
  puts "#{sum_data_array.map(&:to_s).map { |s| s.rjust(5) }.join(' ')} " \
       'total'
end

main
