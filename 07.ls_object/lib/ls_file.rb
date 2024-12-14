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

  def initialize(basename, target_directory)
    @basename = basename
    @target_directory = target_directory
    @path = @target_directory.join(@basename)
    @file_stat = File.lstat(@path)
  end

  def hidden?
    @basename.start_with?('.') || target_directory? || parent_directory?
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

  def current_year?
    Time.now.year == last_modified_time.year
  end

  def last_modified_time
    @file_stat.mtime
  end

  def symlink?
    File.symlink?(@path)
  end

  def name
    if target_directory?
      '.'
    elsif parent_directory?
      '..'
    else
      @basename
    end
  end

  def referenced_file
    File.readlink(@path)
  end

  private

  def target_directory?
    @path == @target_directory
  end

  def parent_directory?
    @path == @target_directory.parent
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
