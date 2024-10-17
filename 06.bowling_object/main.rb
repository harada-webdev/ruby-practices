# frozen_string_literal: true

require_relative 'lib/game'

marks = ARGV[0].split(',')
game = Game.new(marks)
frames = game.create_frames
puts game.calculate_score(frames)
