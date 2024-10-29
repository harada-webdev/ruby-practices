# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(records)
    @frames = create_frames(records)
  end

  def calculate_score
    @frames.each_with_index.sum { |frame, index| frame.score(@frames, index) }
  end

  private

  def create_frames(records)
    marks = []
    frames = []
    records.each do |record|
      marks << record
      if frames.size < 9 && (marks.size >= 2 || record == 'X')
        frames << Frame.new(marks)
        marks.clear
      end
    end
    frames << Frame.new(marks)
  end
end
