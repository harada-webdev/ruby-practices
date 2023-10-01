require 'date'
require 'optparse'

# -mで月を、-yで年を指定できるオプションの生成
calenderOptions = {}
OptionParser.new do |options|
  options.on("-y year",Integer) {|year| calenderOptions[:YEAR] = year}
  options.on("-m month",Integer) {|month| calenderOptions[:MONTH] = month}
end.parse!

# 表示させるカレンダー(年月)の設定
nowDate = Date.today
selectedYear = calenderOptions[:YEAR] || nowDate.year
selectedMonth = calenderOptions[:MONTH] || nowDate.month

# どの年月にも対応した月初日と月末日のインスタンスの生成
firstDay = Date.new(selectedYear, selectedMonth, 1)
lastDay = Date.new(selectedYear, selectedMonth, -1)

# 見出しの作成
puts firstDay.strftime("%B %Y").center(20)
puts "Su Mo Tu We Th Fr Sa"

# 日付の配置(スペースを利用して、対応する曜日と日付を上下に揃えます)
# 今日の日付の部分の色の反転
print "\s\s\s" * firstDay.wday    
(firstDay..lastDay).each do |oneday|
  if oneday == nowDate && oneday.day < 10
    print "\e[7m\s#{oneday.day}\e[0m\s" # 一桁の日付の数値が二桁目の場所に来ないように調整します
  elsif 
    oneday == nowDate && oneday.day >= 10
    print "\e[7m#{oneday.day}\e[0m\s"
  else
    print oneday.day < 10 ? "\s#{oneday.day}\s" : "#{oneday.day}\s"
  end
print "\n" if oneday.saturday? && oneday != lastDay end

puts "\n\n"
