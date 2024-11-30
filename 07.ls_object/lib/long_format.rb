# frozen_string_literal: true

require 'etc'
require 'time'

class LongFormat
  def initialize(file, target_directory, max_length)
    @file = file
    @target_directory = target_directory
    @max_length = max_length
  end

  def show_file
    puts "#{file_type(file_stat)}#{permissions(file_stat)} " \
         "#{file_stat.nlink.to_s.rjust(@max_length[:nlink])} " \
         "#{Etc.getpwuid(file_stat.uid).name.to_s.rjust(@max_length[:username])} " \
         "#{Etc.getpwuid(file_stat.gid).name.to_s.rjust(@max_length[:groupname])} " \
         "#{size_or_device_info(file_stat).to_s.rjust(@max_length[:size])} " \
         "#{last_modified_time(file_stat).to_s.rjust(5)} " \
         "#{directory_or_file_name}"
  end

  private

  def file_stat
    File::Stat.new(@file)
  end

  def file_type(file_stat)
    {
      'fifo' => 'p',
      'characterSpecial' => 'c',
      'directory' => 'd',
      'blockSpecial' => 'b',
      'file' => '-',
      'link' => 'l',
      'socket' => 's'
    }[file_stat.ftype]
  end

  def permissions(file_stat)
    ocatal_mode = file_stat.mode.to_s(8)
    permissions = ocatal_mode[-3..].chars.map do |mode|
      ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'][mode.to_i]
    end
    add_special_permissions(ocatal_mode, permissions)
    permissions.join
  end

  def add_special_permissions(ocatal_mode, permissions)
    case ocatal_mode[2]
    when '1'
      permissions[2] = permissions[2].chop + (permissions[2][2] == 'x' ? 't' : 'T')
    when '2'
      permissions[1] = permissions[1].chop + (permissions[1][2] == 'x' ? 's' : 'S')
    when '4'
      permissions[0] = permissions[0].chop + (permissions[0][2] == 'x' ? 's' : 'S')
    end
  end

  def size_or_device_info(file_stat)
    if file_stat.rdev.zero?
      file_stat.size
    else
      "#{file_stat.rdev_major}, #{file_stat.rdev_minor}"
    end
  end

  def last_modified_time(file_stat)
    if Time.now.year == file_stat.mtime.year
      file_stat.mtime.strftime('%b %e %H:%M')
    else
      file_stat.mtime.strftime('%b %e  %Y')
    end
  end

  def directory_or_file_name
    if @file == @target_directory
      '.'
    elsif @file == @target_directory.parent
      '..'
    elsif File.symlink?(@file)
      "#{@file} -> #{File.readlink(@file)}"
    else
      File.basename(@file)
    end
  end
end
