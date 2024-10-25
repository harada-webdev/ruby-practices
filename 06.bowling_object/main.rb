# frozen_string_literal: true

require_relative 'lib/game'

records = ARGV[0].split(',')
game = Game.new(records)
puts game.calculate_score
