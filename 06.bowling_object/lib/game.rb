# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(marks)
    @marks = marks
  end

  def create_frames
    frame = []
    frames = []
    @marks.each do |mark|
      frame << mark
      if frames.size < 10 && (frame.size >= 2 || mark == 'X')
        frames << frame.clone
        frame.clear
      end
    end
    frames.last.concat(frame)
    frames
  end

  def calculate_score(frames)
    @frames = frames
    score = 0
    10.times do |index|
      frame = Frame.new(@frames[index])
      score += frame.score == 10 && index < 9 ? calculate_bonus_score(frame, index) : frame.score
    end
    score
  end

  private

  def calculate_bonus_score(frame, index)
    next_first_mark = Mark.new(@frames[index + 1][0]).score
    next_second_mark = Mark.new(@frames[index + 1][1]).score
    after_next_first_mark = Mark.new(@frames[index + 2][0]).score if index < 8

    if frame.first_mark.score == 10
      if next_first_mark == 10 && index < 8
        20 + after_next_first_mark
      else
        10 + next_first_mark + next_second_mark
      end
    else
      10 + next_first_mark
    end
  end
end
