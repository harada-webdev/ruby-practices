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

  def test_calculate_score1
    game = Game.new(%w[6 3 9 0 0 3 8 2 7 3 X 9 1 8 0 X 6 4 5])
    assert_equal 139, game.calculate_score
  end

  def test_calculate_score2
    game = Game.new(%w[6 3 9 0 0 3 8 2 7 3 X 9 1 8 0 X X X X])
    assert_equal 164, game.calculate_score
  end

  def test_calculate_score3
    game = Game.new(%w[0 10 1 5 0 0 0 0 X X X 5 1 8 1 0 4])
    assert_equal 107, game.calculate_score
  end

  def test_calculate_score4
    game = Game.new(%w[6 3 9 0 0 3 8 2 7 3 X 9 1 8 0 X X 0 0])
    assert_equal 134, game.calculate_score
  end

  def test_calculate_score5
    game = Game.new(%w[6 3 9 0 0 3 8 2 7 3 X 9 1 8 0 X X 1 8])
    assert_equal 144, game.calculate_score
  end

  def test_calculate_score6
    game = Game.new(%w[X X X X X X X X X X X X])
    assert_equal 300, game.calculate_score
  end

  def test_calculate_score7
    game = Game.new(%w[X X X X X X X X X X X 2])
    assert_equal 292, game.calculate_score
  end

  def test_calculate_score8
    game = Game.new(%w[X 0 0 X 0 0 X 0 0 X 0 0 X 0 0])
    assert_equal 50, game.calculate_score
  end
end
