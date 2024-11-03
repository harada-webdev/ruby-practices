# frozen_string_literal: true

require_relative 'file_information'

class LongFormat
  include FileInformation

  def initialize(file)
    @file = file
  end

  def show_file
    puts "#{type} " \
         "#{nlink.to_s.rjust(2)} " \
         "#{owner_name} #{group_name} " \
         "#{size.to_s.rjust(4)} " \
         "#{mtime} " \
         "#{basename}"
  end
end
