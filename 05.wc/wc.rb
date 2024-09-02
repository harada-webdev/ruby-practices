# frozen_string_literal: true

require 'optparse'

def main
  totals = { lines: 0, words: 0, chars: 0 }
  files, options = parse_command_line_arguments

  files.each do |file_info|
    file = file_info[:file]
    file_name = file_info[:file_name]

    counts = generate_counts(file)
    display_counts(counts, file_name, options)
    update_totals(counts, options, totals)

    file.close unless file_name.nil?
  end

  display_totals(options, totals) if files.count > 1
end

def parse_command_line_arguments
  options = {}

  OptionParser.new do |opts|
    opts.on('-l') { options[:l] = true }
    opts.on('-w') { options[:w] = true }
    opts.on('-c') { options[:c] = true }

    opts.parse!(ARGV)
  end

  files = if ARGV.empty?
            [{ file_name: nil, file: $stdin }]
          else
            ARGV.map do |f|
              { file_name: f, file: File.open(f) }
            end
          end

  [files, options]
end

def generate_counts(file)
  file_content = file.read
  {
    'l' => file_content.split("\n").size,
    'w' => file_content.split.size,
    'c' => file_content.size
  }
end

def display_counts(counts, file_name, options)
  if options.empty?
    puts "#{counts['l'].to_s.rjust(5)} " \
         "#{counts['w'].to_s.rjust(5)} " \
         "#{counts['c'].to_s.rjust(5)} " \
         "#{file_name unless file_name.nil?}"
  else
    puts "#{counts['l'].to_s.rjust(5) if options[:l]} " \
         "#{counts['w'].to_s.rjust(5) if options[:w]} " \
         "#{counts['c'].to_s.rjust(5) if options[:c]} " \
         "#{file_name unless file_name.nil?}"
  end
end

def update_totals(counts, options, totals)
  if options.empty?
    totals[:lines] += counts['l']
    totals[:words] += counts['w']
    totals[:chars] += counts['c']
  else
    totals[:lines] += counts['l'] if options[:l]
    totals[:words] += counts['w'] if options[:w]
    totals[:chars] += counts['c'] if options[:c]
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
