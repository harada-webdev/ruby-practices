# frozen_string_literal: true

require 'optparse'

def main
  totals = { lines: 0, words: 0, chars: 0 }
  files, options = parse_command_line_arguments

  files.each do |file|
    all_counts, counts = generate_counts(file, options)
    display_counts(all_counts, counts, file, options)
    update_totals(all_counts, counts, options, totals)
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

def generate_counts(file, options)
  file_content = file == $stdin ? $stdin.read : File.read(file)
  all_counts = {
    'l' => file_content.split("\n").size,
    'w' => file_content.split.size,
    'c' => file_content.size
  }
  counts = []

  all_counts.each do |option, data|
    counts << data if options.include?(option)
  end

  [all_counts, counts]
end

def display_counts(all_counts, counts, file, options)
  if options.empty?
    puts "#{all_counts['l'].to_s.rjust(5)} " \
         "#{all_counts['w'].to_s.rjust(5)} " \
         "#{all_counts['c'].to_s.rjust(5)} " \
         "#{file if file != $stdin}"
  else
    puts "#{counts.map(&:to_s).map { |count| count.rjust(5) }.join(' ')} " \
         "#{file if file != $stdin}"
  end
end

def update_totals(all_counts, counts, options, totals)
  if options.empty?
    totals[:lines] += all_counts['l']
    totals[:words] += all_counts['w']
    totals[:chars] += all_counts['c']
  else
    totals[:lines] += counts[0]
    totals[:words] += counts[1] || 0
    totals[:chars] += counts[2] || 0
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
