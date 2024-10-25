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
        frame.bonus_score(@frames, frame, index)
      else
        frame.score
      end
    end
  end
end
