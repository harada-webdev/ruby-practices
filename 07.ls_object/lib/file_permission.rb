# frozen_string_literal: true

module FilePermission
  def add_permissions(file_stat)
    ocatal_mode = file_stat.mode.to_s(8)
    permissions = ocatal_mode[-3..].chars.map do |mode|
      ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'][mode.to_i]
    end
    add_special_permissions(ocatal_mode, permissions)
    permissions.join
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
