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
    base_bonus_score = 10 + next_frame.first_mark.score
    if strike?
      if next_frame.strike? && after_next_frame
        base_bonus_score + after_next_frame.first_mark.score
      else
        base_bonus_score + next_frame.second_mark.score
      end
    else
      base_bonus_score
    end
  end

  def spare?
    @first_mark.score + @second_mark.score == 10
  end

  public

  def strike?
    @first_mark.score == 10
  end
end
