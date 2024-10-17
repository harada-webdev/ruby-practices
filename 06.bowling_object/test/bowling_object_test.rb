# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/mark'

class BowlingObjectTest < Minitest::Test
  def test_mark_score1
    mark = Mark.new('X')
    assert_equal 10, mark.score
  end

  def test_mark_score2
    mark = Mark.new('0')
    assert_equal 0, mark.score
  end
end
