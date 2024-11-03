# frozen_string_literal: true

class DefaultFormat
  def initialize(files_array)
    @files_array = files_array
  end

  def show_file
    puts @files_array.compact.map { |file| File.basename(file).ljust(20) }.join
  end
end
