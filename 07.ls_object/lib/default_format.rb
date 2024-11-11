# frozen_string_literal: true

class DefaultFormat
  def initialize(files_array, target_directory)
    @files_array = files_array
    @target_directory = target_directory
  end

  def show_file
    puts @files_array.compact.map { |file| directory_or_file_name(file).ljust(20) }.join
  end

  private

  def directory_or_file_name(file)
    if file == @target_directory
      '.'
    elsif file == @target_directory.parent
      '..'
    else
      File.basename(file)
    end
  end
end
