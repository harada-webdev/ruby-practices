# frozen_string_literal: true

require 'date'
require 'optparse'

# -mで月を、-yで年を指定できるオプションの生成
calender_options = {}
OptionParser.new do |options|
  options.on('-y year', Integer) { |year| calender_options[:year] = year }
  options.on('-m month', Integer) { |month| calender_options[:month] = month }
end.parse!

# 表示させるカレンダー(年月)の設定
now_date = Date.today
selected_year = calender_options[:year] || now_date.year
selected_month = calender_options[:month] || now_date.month

# どの年月にも対応した月初日と月末日のインスタンスの生成
first_day = Date.new(selected_year, selected_month, 1)
last_day = Date.new(selected_year, selected_month, -1)

# 見出しの作成
puts first_day.strftime('%B %Y').center(20)
puts 'Su Mo Tu We Th Fr Sa'

# 日付の配置(スペースを利用して、対応する曜日と日付を上下に揃えます)
# 今日の日付の部分の色の反転
print "\s\s\s" * first_day.wday
(first_day..last_day).each do |oneday|
  if oneday == now_date
    print "\e[7m#{oneday.day.to_s.rjust(2)}\e[0m\s"
  else
    print "#{oneday.day.to_s.rjust(2)}\s"
  end
  print "\n" if oneday.saturday? && oneday != last_day
end

puts "\n\n"
