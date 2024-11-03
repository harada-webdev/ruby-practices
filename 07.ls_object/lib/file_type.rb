# frozen_string_literal: true

module FileType
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
end
