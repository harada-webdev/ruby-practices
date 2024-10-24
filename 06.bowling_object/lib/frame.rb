# frozen_string_literal: true

require_relative 'mark'

class Frame
  attr_reader :first_mark, :second_mark

  def initialize(frame)
    @first_mark = Mark.new(frame[0])
    @second_mark = Mark.new(frame[1])
    @third_mark = Mark.new(frame[2])
  end

  def score
    [@first_mark.score, @second_mark.score, @third_mark.score].sum
  end
end
