# frozen_string_literal: true

require 'etc'

class MaxLength
  def initialize(files)
    @files = files
  end

  def file_name
    @files[0, 11].map { |file| File.basename(file).to_s.length }.max + 1
  end

  def file_information
    files_stat = @files.map { |file| File.lstat(file) }
    {
      nlink: files_stat.map { |file_stat| file_stat.nlink.to_s.length }.max,
      username: files_stat.map { |file_stat| Etc.getpwuid(file_stat.uid).name.to_s.length }.max,
      groupname: files_stat.map { |file_stat| Etc.getpwuid(file_stat.gid).name.to_s.length }.max,
      size: files_stat.map { |file_stat| size_or_device_info(file_stat).to_s.length }.max
    }
  end

  def size_or_device_info(file_stat)
    if file_stat.rdev.zero?
      file_stat.size
    else
      "#{file_stat.rdev_major}, #{file_stat.rdev_minor}"
    end
  end
end
