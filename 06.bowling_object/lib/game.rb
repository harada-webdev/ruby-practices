# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(marks)
    @frames = create_frames(marks)
  end

  private

  def create_frames(marks)
    frame = []
    frames = []
    marks.each do |mark|
      frame << mark
      if frames.size < 9 && (frame.size >= 2 || mark == 'X')
        frames << Frame.new(frame)
        frame.clear
      end
    end
    frames << Frame.new(frame)
  end

  public

  def calculate_score
    @frames.each_with_index.sum do |frame, index|
      if frame.score == 10 && index < 9
        next_first_mark = @frames[index + 1].first_mark.score
        next_second_mark = @frames[index + 1].second_mark.score
        after_next_first_mark = @frames[index + 2].first_mark.score if index < 8
        frame.bonus_score(frame, next_first_mark, next_second_mark, after_next_first_mark)
      else
        frame.score
      end
    end
  end
end
