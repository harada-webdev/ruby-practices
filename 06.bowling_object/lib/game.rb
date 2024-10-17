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
end
