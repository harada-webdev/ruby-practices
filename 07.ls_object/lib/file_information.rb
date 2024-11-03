# frozen_string_literal: true

require 'etc'
require 'time'
require_relative 'file_type'
require_relative 'file_permission'

module FileInformation
  include FileType
  include FilePermission

  def block_size(file)
    File::Stat.new(file).blocks / 2
  end

  def type
    convert_file_type(file_stat)
  end

  def permissions
    add_permissions(file_stat)
  end

  def nlink
    file_stat.nlink
  end

  def owner_name
    Etc.getpwuid(file_stat.uid).name
  end

  def group_name
    Etc.getgrgid(file_stat.gid).name
  end

  def size
    file_stat.size
  end

  def mtime
    File.mtime(@file).strftime('%b %e %H:%M')
  end

  def basename
    File.basename(@file)
  end

  private

  def file_stat
    File::Stat.new(@file)
  end
end
