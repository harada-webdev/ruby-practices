# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

point = frames.each_with_index.sum do |frame, index|
  strike = frame[0] == 10
  spare = !strike && frame.sum == 10
  next_frame = frames[index + 1]
  after_next_frame = frames[index + 2]

  if strike
    if index < 9
      if next_frame[0] == 10
        20 + after_next_frame[0]
      else
        10 + next_frame.sum
      end
    else
      frame.sum
    end
  elsif spare
    if index < 9
      10 + next_frame[0]
    else
      frame.sum
    end
  else
    frame.sum
  end
end

puts point
