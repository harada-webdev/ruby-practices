# frozen_string_literal: true

require 'etc'

class LsFile
  attr_reader :file_stat

  TYPES = {
    'fifo' => 'p',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'blockSpecial' => 'b',
    'file' => '-',
    'link' => 'l',
    'socket' => 's'
  }.each do |k, v|
    k.freeze
    v.freeze
  end.freeze

  PERMISSIONS = [
    '---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'
  ].map(&:freeze).freeze

  def initialize(file, target_directory, options)
    @file = file
    @target_directory = target_directory
    @options = options
    @file_stat = File.lstat(@file)
  end

  def block_size
    @file_stat.blocks / 2
  end

  def mode
    "#{type}#{permission}"
  end

  def hard_links
    @file_stat.nlink
  end

  def owner_name
    Etc.getpwuid(@file_stat.uid).name
  end

  def owner_group_name
    Etc.getpwuid(@file_stat.gid).name
  end

  def size_or_device_info
    if @file_stat.rdev.zero?
      @file_stat.size
    else
      "#{@file_stat.rdev_major}, #{@file_stat.rdev_minor}"
    end
  end

  def last_modified_time
    @file_stat.mtime
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

  def type
    TYPES[@file_stat.ftype]
  end

  def permission
    ocatal_mode = @file_stat.mode.to_s(8)
    permissions = ocatal_mode[-3..].chars.map do |mode|
      PERMISSIONS[mode.to_i]
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
end
