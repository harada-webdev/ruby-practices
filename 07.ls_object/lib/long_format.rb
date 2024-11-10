# frozen_string_literal: true

require 'etc'
require 'time'

class LongFormat
  def initialize(file)
    @file = file
  end

  def show_file
    puts "#{convert_file_type(file_stat)}#{add_permissions(file_stat)} " \
         "#{file_stat.nlink.to_s.rjust(2)} " \
         "#{Etc.getpwuid(file_stat.uid).name} #{Etc.getgrgid(file_stat.gid).name} " \
         "#{file_stat.size.to_s.rjust(4)} " \
         "#{File.mtime(@file).strftime('%b %e %H:%M').to_s.rjust(4)} " \
         "#{File.basename(@file)}"
  end

  private

  def file_stat
    File::Stat.new(@file)
  end

  def convert_file_type(file_stat)
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

  def add_permissions(file_stat)
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
end
