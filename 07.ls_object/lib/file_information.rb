# frozen_string_literal: true

require 'etc'
require 'time'

module FileInformation
  def block_size(file)
    File::Stat.new(file).blocks / 2
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
