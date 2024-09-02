# frozen_string_literal: true

require 'optparse'

def main
  files, options = parse_command_line_arguments
  totals = { lines: 0, words: 0, chars: 0 }

  files.each do |file_info|
    file = file_info[:file]
    name = file_info[:name]
    content = file.read
    counts = { lines: content.split("\n").size, words: content.split.size, chars: content.size }

    display_counts(counts, name, options)

    %i[lines words chars].each { |key| totals[key] += counts[key] if options[key] }
    file.close unless name.nil?
  end

  display_totals(options, totals) if files.count > 1
end

def parse_command_line_arguments
  options = { lines: false, words: false, chars: false }

  OptionParser.new do |opts|
    opts.on('-l') { options[:lines] = true }
    opts.on('-w') { options[:words] = true }
    opts.on('-c') { options[:chars] = true }

    opts.parse!(ARGV)
  end
  options.transform_values! { true } if options.values.all?(false)

  files = if ARGV.empty?
            [{ name: nil, file: $stdin }]
          else
            ARGV.map do |f|
              { name: f, file: File.open(f) }
            end
          end

  [files, options]
end

def display_counts(counts, name, options)
  line_counts = "#{counts[:lines].to_s.rjust(5)} " if options[:lines]
  word_counts = "#{counts[:words].to_s.rjust(5)} " if options[:words]
  char_counts = "#{counts[:chars].to_s.rjust(5)} " if options[:chars]
  name = name.rjust(10).to_s unless name.nil?

  puts "#{line_counts}#{word_counts}#{char_counts}#{name}"
end

def display_totals(options, totals)
  extracted_totals = []
  options.each { |key, boolean| extracted_totals << totals[key] if boolean }

  puts "#{extracted_totals.map(&:to_s).map { |total| total.rjust(5) }.join(' ')} " \
       "#{'total'.rjust(10)}"
end

main
