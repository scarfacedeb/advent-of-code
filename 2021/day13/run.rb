require "benchmark"

def read_input
  file = $all ? "input.txt" : "example.txt"
  input = File.read(ARGV.last || file).split("\n")
  dots, folds = input.slice_after("").to_a
  dots = dots.map { _1.split(",").map(&:to_i) }.reject(&:empty?)
  folds = folds.map { _1.match(/fold along ([yx])=(\d+)/) { |m| [m[1].to_sym, m[2].to_i] } }
  [dots, folds]
end

def build_matrix(dots)
  index = dots.reduce({}) { |acc, (x, y)|
    acc[y] ||= {}
    acc[y][x] = 1
    acc
  }

  rows = dots.map(&:last).max + 1
  cols = dots.map(&:first).max + 1

  rows.times.map { |y|
    cols.times.map { |x|
      index.dig(y, x)
    }
  }
end

def draw(matrix)
  puts matrix.map { |row| row.map { _1 ? "#" : "." }.join }.join("\n")
  matrix
end

def foldX(matrix, coord)
  split = matrix.map { |row| row.each_slice(coord + 1).to_a }

  split.map { |row|
    left, right = row
    left.pop
    right.each.with_index(1) do |val, x|
      left[-x] ||= val
    end
    left
  }
end

def foldY(matrix, coord)
  top, bottom = matrix.each_slice(coord + 1).to_a
  top.pop

  bottom.each.with_index(1) do |row, y|
    row.each_with_index { |val, x|
      top[-y][x] ||= val
    }
  end

  top
end

p Benchmark.measure {

dots, folds = read_input

matrix = build_matrix(dots)

first_fold = nil

folded =
  folds.reduce(matrix) { |m, fold|
    axis, coord = fold
    fld = axis == :x ? foldX(m, coord) : foldY(m, coord)
    first_fold ||= fld
    fld
  }

ans = first_fold.flatten.compact.count

puts "Answer 13.1: #{ans}"
puts "Answer 13.2:"
draw(folded)

# binding.pry

}.total * 1000
