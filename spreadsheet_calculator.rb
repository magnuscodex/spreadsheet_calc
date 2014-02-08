#!/usr/bin/env ruby

$N,$M = $stdin.gets.chomp.split().map{|e| e.to_i}

# Spreadsheet is an N by M array of cells.
# Each Cell is a list of three arrays: [STACK, DEPENDENCIES, BLOCKED]
# The stack in a cell is its RPN format input. The dependencies are the cells
# that are needed to compute it's value and the blocked is a list of cells that
# need this cell to compute there result.
sheet = [nil] * $M
for i in (0...$M)
  sheet[i] = [nil] * $N
  for j in (0...$N)
    sheet[i][j] = [[],[],[]]
  end
end

def tokenize(input)
  if m = input.match(/^(\d+)$/)
    return m[1].to_f
  elsif m = input.match(/^([\+\-\/\*])$/)
    return m[1]
  elsif m = input.match(/^([A-Z])(\d+)$/)
    row = m[1].ord - "A"[0].ord
    if row >= $M
      puts "Row #{m[1]} is out of bounds."
      exit 1
    end
    return [row, m[2].to_i - 1]
  else
    puts "Unknown symbol #{input}"
    exit 3
  end
end

for i in (0...$M)
  for j in (0...$N)
    input_stack = $stdin.gets.chomp.split()
    for e in input_stack
      sym = tokenize(e)
      if sym.class == Array
        sheet[i][j][0] << sym
        sheet[i][j][1] << sym
        sheet[sym[0]][sym[1]][2] << [i,j]
      else
        sheet[i][j][0] << sym
      end
    end
  end
end

#for i in (0...$M)
#  for j in (0...$N)
#    puts "#{i},#{j}"
#    puts "stack:#{sheet[i][j][0].join(",")} dep:#{sheet[i][j][1].join(",")} block:#{sheet[i][j][2].join(",")}"
#  end
#  puts "===="
#end

def calculate_cell(row, col, sheet, ready)
  #can't calculate a row with dependencies 
  if not sheet[row][col][1].empty?
    return false
  end

  elements = []
  for operand in sheet[row][col][0]
    if operand.is_a?Float
      elements << operand
    elsif operand.is_a? Array
      elements << sheet[operand[0]][operand[1]][0] # We assume it's solved
    elsif operand == "+"
      vals = elements.pop(2)
      elements << vals[0] + vals[1]
    elsif operand == "-"
      vals = elements.pop(2)
      elements << vals[0] - vals[1]
    elsif operand == "*"
      vals = elements.pop(2)
      elements << vals[0] * vals[1]
    elsif operand == "/"
      vals = elements.pop(2)
      elements << vals[0] / vals[1]
    else
      puts "Unknown operand #{operand}"
      exit 3
    end
  end
  sheet[row][col][0] = elements[0]
  for blocked in sheet[row][col][2]
    sheet[blocked[0]][blocked[1]][1].delete([row,col])
    if sheet[blocked[0]][blocked[1]][1].empty?
      ready << blocked
    end
  end
  return true
end

ready_to_compute = []
for i in (0...$M)
  for j in (0...$N)
    if sheet[i][j][1].empty?
      ready_to_compute << [i,j]
    end
  end
end

#for e in ready_to_compute
#  puts e.join(",")
#end

calculated = 0

while not ready_to_compute.empty?
  curr = ready_to_compute.shift
  calculate_cell(curr[0], curr[1], sheet, ready_to_compute)
  calculated += 1
end

if calculated < $N * $M
  puts "Unresolved dependencies"
  puts calculated
  exit 1
end

puts "#{$N} #{$M}"
for i in (0...$M)
  for j in (0...$N)
    puts "%.5f" % sheet[i][j][0]
  end
end
