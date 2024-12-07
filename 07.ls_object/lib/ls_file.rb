# frozen_string_literal: true

require 'etc'
require 'time'

class LsFile
  def initialize(file, target_directory, options)
    @file = file
    @target_directory = target_directory
    @options = options
  end

  def block_size
    file_stat.blocks / 2
  end

  def file_stat
    File.lstat(@file)
  end

  def type
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

  def permissions
    ocatal_mode = file_stat.mode.to_s(8)
    permissions = ocatal_mode[-3..].chars.map do |mode|
      ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'][mode.to_i]
    end
    add_special_permissions(ocatal_mode, permissions)
    permissions.join
  end

  def hard_links
    file_stat.nlink
  end

  def owner_name
    Etc.getpwuid(file_stat.uid).name
  end

  def owner_group_name
    Etc.getpwuid(file_stat.gid).name
  end

  def size_or_device_info
    if file_stat.rdev.zero?
      file_stat.size
    else
      "#{file_stat.rdev_major}, #{file_stat.rdev_minor}"
    end
  end

  def last_modified_time
    if Time.now.year == file_stat.mtime.year
      file_stat.mtime.strftime('%b %e %H:%M')
    else
      file_stat.mtime.strftime('%b %e  %Y')
    end
  end

  def name
    if @file == @target_directory
      '.'
    elsif @file == @target_directory.parent
      '..'
    elsif File.symlink?(@file) && @options[:long]
      "#{@file} -> #{File.readlink(@file)}"
    else
      File.basename(@file)
    end
  end

  private

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
end
