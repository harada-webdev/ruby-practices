# frozen_string_literal: true

require 'optparse'

def main
  totals = { first: 0, second: 0, third: 0 }
  files, options = parse_command_line_arguments

  files.each do |file|
    all_counted_data, counted_data = generate_counted_data(file, options)
    display_each_data(all_counted_data, counted_data, file, options)
    update_totals(all_counted_data, counted_data, options, totals)
  end

  display_totals(options, totals) if files.count > 1
end

def parse_command_line_arguments
  options = ''

  OptionParser.new do |opts|
    opts.on('-l') { options += 'l' }
    opts.on('-w') { options += 'w' }
    opts.on('-c') { options += 'c' }

    opts.parse!(ARGV)
  end

  files = ARGV.empty? ? [$stdin] : ARGV

  [files, options]
end

def generate_counted_data(file, options)
  file_content = file == $stdin ? $stdin.read : File.read(file)
  all_counted_data = {
    'l' => file_content.split("\n").size,
    'w' => file_content.split.size,
    'c' => file_content.size
  }
  counted_data = []

  all_counted_data.each do |option, data|
    counted_data << data if options.include?(option)
  end

  [all_counted_data, counted_data]
end

def display_each_data(all_counted_data, counted_data, file, options)
  if options.empty?
    puts "#{all_counted_data['l'].to_s.rjust(5)} " \
         "#{all_counted_data['w'].to_s.rjust(5)} " \
         "#{all_counted_data['c'].to_s.rjust(5)} " \
         "#{file if file != $stdin}"
  else
    puts "#{counted_data.map(&:to_s).map { |data| data.rjust(5) }.join(' ')} " \
         "#{file if file != $stdin}"
  end
end

def update_totals(all_counted_data, counted_data, options, totals)
  if options.empty?
    totals[:first] += all_counted_data['l']
    totals[:second] += all_counted_data['w']
    totals[:third] += all_counted_data['c']
  else
    totals[:first] += counted_data[0]
    totals[:second] += counted_data[1] || 0
    totals[:third] += counted_data[2] || 0
  end
end

def display_totals(options, totals)
  extracted_totals = []

  totals.each_with_index do |(_order, total), index|
    break if !options.empty? && options.length <= index

    extracted_totals << total
  end

  puts "#{extracted_totals.map(&:to_s).map { |total| total.rjust(5) }.join(' ')} " \
       'totals'
end

main
