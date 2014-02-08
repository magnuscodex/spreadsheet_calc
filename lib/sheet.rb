#!/usr/bin/env ruby

class Sheet
  def initialize(width, height)
    # Spreadsheet is an width by height array of cells.
    # Each Cell is a list of three arrays: [STACK, DEPENDENCIES, BLOCKED]
    # The stack in a cell is its RPN format input. The dependencies are
    # the cells that are needed to compute it's value and the blocked
    # is a list of cells that need this cell to compute there result.
    @sheet = [nil] * height
    for i in (0...height)
      @sheet[i] = [nil] * width
      for j in (0...width)
        @sheet[i][j] = [[],[],[]]
      end
    end
    @width = width
    @height = height
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
      return false
    end
  end

  def input_cell(row, col, expression)
    input_stack = expression.split()

    for e in input_stack
      # If tokenizing a symbol fails return false
      sym = tokenize(e)
      if not sym
        return false
      end
      if sym.class == Array
        @sheet[row][col][0] << sym
        @sheet[row][col][1] << sym
        @sheet[sym[0]][sym[1]][2] << [row,col]
      else
        @sheet[row][col][0] << sym
      end
    end
    return true
  end

  def calculate()
    ready_to_compute = []
    for i in (0...@height)
      for j in (0...@width)
        if @sheet[i][j][1].empty?
          ready_to_compute << [i,j]
        end
      end
    end
    
    calculated = 0
    
    while not ready_to_compute.empty?
      curr = ready_to_compute.shift
      ret = calculate_cell(curr[0], curr[1], ready_to_compute)
      if not ret
        puts "Failure calculating #{curr[0]},#{curr[1]}"
        return false
      end
      calculated += 1
    end
    
    if calculated < @width * @height
      return false
    end
    return true
  end


  def calculate_cell(row, col, ready)
    #can't calculate a row with dependencies 
    if not @sheet[row][col][1].empty?
      return false
    end
  
    elements = []
    for operand in @sheet[row][col][0]
      if operand.is_a?Float
        elements << operand
      elsif operand.is_a? Array
        elements << @sheet[operand[0]][operand[1]][0] # We assume it's solved
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
        return false
      end
    end
    @sheet[row][col][0] = elements[0]
    for blocked in @sheet[row][col][2]
      @sheet[blocked[0]][blocked[1]][1].delete([row,col])
      if @sheet[blocked[0]][blocked[1]][1].empty?
        ready << blocked
      end
    end
    return true
  end


  def to_s
    out = []
    out << "#{@width} #{@height}"
    for i in (0...@height)
      for j in (0...@width)
        out << "%.5f" % @sheet[i][j][0]
      end
    end
    ret = out.join("\n")
    return ret
  end
end

