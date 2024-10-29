# frozen_string_literal: true

require_relative 'mark'

class Frame
  attr_reader :first_mark, :second_mark

  def initialize(marks)
    @first_mark, @second_mark, @third_mark = (0..2).map { |i| Mark.new(marks[i]) }
  end

  def score(frames, index)
    if (strike? || spare?) && index < 9
      bonus_score(frames[index + 1], frames[index + 2])
    else
      [@first_mark, @second_mark, @third_mark].map(&:score).sum
    end
  end

  def strike?
    @first_mark.score == 10
  end

  private

  def spare?
    @first_mark.score + @second_mark.score == 10
  end

  def bonus_score(next_frame, after_next_frame = nil)
    10 + next_frame.first_mark.score + if strike?
                                         if next_frame.strike? && after_next_frame
                                           after_next_frame.first_mark.score
                                         else
                                           next_frame.second_mark.score
                                         end
                                       else
                                         0
                                       end
  end
end
