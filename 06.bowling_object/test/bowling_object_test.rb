# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/mark'
require_relative '../lib/frame'
require_relative '../lib/game'

class BowlingObjectTest < Minitest::Test
  def test_mark_score1
    mark = Mark.new('X')
    assert_equal 10, mark.score
  end

  def test_mark_score2
    mark = Mark.new('0')
    assert_equal 0, mark.score
  end

  def test_frame_score
    frame = Frame.new(%w[0 10])
    assert_equal 10, frame.score
  end

  def test_create_frames
    game = Game.new(%w[6 3 9 0 0 3 8 2 7 3 X 9 1 8 0 X 6 4 5])
    assert_equal [%w[6 3], %w[9 0], %w[0 3], %w[8 2], %w[7 3], ['X'], %w[9 1], %w[8 0], ['X'], %w[6 4 5]], game.create_frames
  end
end
