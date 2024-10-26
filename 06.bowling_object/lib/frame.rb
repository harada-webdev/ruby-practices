# frozen_string_literal: true

require_relative 'mark'

class Frame
  attr_reader :first_mark, :second_mark

  def initialize(marks)
    @first_mark, @second_mark, @third_mark = (0..2).map { |i| Mark.new(marks[i]) }
  end

  def score(frames, index)
    if (spare? || strike?) && index < 9
      bonus_score(frames[index + 1], frames[index + 2])
    else
      [@first_mark, @second_mark, @third_mark].map(&:score).sum
    end
  end

  private

  def bonus_score(next_frame, after_next_frame = nil)
    next_first_mark = next_frame.first_mark.score
    next_second_mark = next_frame.second_mark.score
    after_next_first_mark = after_next_frame.first_mark.score if after_next_frame

    if strike?
      if next_first_mark == 10 && after_next_first_mark
        20 + after_next_first_mark
      else
        10 + next_first_mark + next_second_mark
      end
    else
      10 + next_first_mark
    end
  end

  def spare?
    @first_mark.score + @second_mark.score == 10
  end

  def strike?
    @first_mark.score == 10
  end
end
