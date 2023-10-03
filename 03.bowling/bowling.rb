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

frames = []
shots.each_slice(2) do |s|
  frames << s
end

point = 0
frames.each_with_index do |frame, index|
  point += if frame[0] == 10 # strike
             if index < 9
               if frames[index + 1][0] == 10
                 20 + frames[index + 2][0]
               else
                 10 + frames[index + 1].sum
               end
             else
               frame.sum
             end
           elsif frame.sum == 10 # spare
             if index < 9
               10 + frames[index + 1][0]
             else
               frame.sum
             end
           else
             frame.sum
           end
end

puts point
