#!/usr/bin/env ruby

require "./lib/sheet.rb"

$N,$M = $stdin.gets.chomp.split().map{|e| e.to_i}

sheet = Sheet.new($N, $M)

for i in (0...$M)
  for j in (0...$N)
    input_expression = $stdin.gets.chomp
    sheet.input_cell(i, j, input_expression)
  end
end

ret = sheet.calculate()
if not ret
  puts "Error calculating"
  exit 2
end

puts sheet
