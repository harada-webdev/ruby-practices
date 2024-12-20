# frozen_string_literal: true

class Mark
  def initialize(mark)
    @mark = mark
  end

  def score
    @mark == 'X' ? 10 : @mark.to_i
  end
end
