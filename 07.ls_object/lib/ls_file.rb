# frozen_string_literal: true

require 'etc'

class LsFile
  include Comparable

  TYPES = {
    'fifo' => 'p',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'blockSpecial' => 'b',
    'file' => '-',
    'link' => 'l',
    'socket' => 's'
  }.freeze

  PERMISSIONS = [
    '---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'
  ].freeze

  def initialize(file, target_directory, options)
    @file = file
    @target_directory = target_directory
    @options = options
    @file_path = @target_directory.join(@file)
    @file_stat = File.lstat(@file_path)
  end

  def hidden?
    @file.start_with?('.') || target_directory? || parent_directory?
  end

  def <=>(other)
    name.sub(/^\./, '') <=> other.name.sub(/^\./, '')
  end

  def block_size
    @file_stat.blocks / 2
  end

  def mode
    "#{TYPES[@file_stat.ftype]}#{permission}"
  end

  def hard_links
    @file_stat.nlink
  end

  def owner_name
    Etc.getpwuid(@file_stat.uid).name
  end

  def owner_group_name
    Etc.getgrgid(@file_stat.gid).name
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
    if target_directory?
      '.'
    elsif parent_directory?
      '..'
    elsif File.symlink?(@file_path) && @options[:long]
      "#{@file} -> #{File.readlink(@file_path)}"
    else
      @file
    end
  end

  private

  def target_directory?
    @file_path == @target_directory
  end

  def parent_directory?
    @file_path == @target_directory.parent
  end

  def permission
    ocatal_mode = @file_stat.mode.to_s(8).rjust(6, '0')
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
