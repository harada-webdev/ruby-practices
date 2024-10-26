# frozen_string_literal: true

require_relative 'mark'

class Frame
  attr_reader :first_mark, :second_mark

  def initialize(marks)
    marks[1] ||= 0
    marks[2] ||= 0
    @first_mark, @second_mark, @third_mark = marks.map { Mark.new(_1) }
  end

  def score(frames, index)
    if (spare? || strike?) && index < 9
      bonus_score(frames, index)
    else
      [@first_mark, @second_mark, @third_mark].map(&:score).sum
    end
  end

  private

  def bonus_score(frames, index)
    next_first_mark = frames[index + 1].first_mark.score
    next_second_mark = frames[index + 1].second_mark.score
    after_next_first_mark = frames[index + 2].first_mark.score if index < 8

    if strike?
      if next_first_mark == 10 && !after_next_first_mark.nil?
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
