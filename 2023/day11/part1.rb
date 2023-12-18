require "debug" if ENV["DEBUG"]

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n")
end

def expand_rows(grid)
  grid.map { |row| row.all? { _1 == "." } ? [row, row] : [row] }.flatten(1)
end

def expand_cols(grid)
  grid.transpose.then { expand_rows(_1) }.transpose
end

def color(val, code)
  "\e[#{code}m#{val}\e[0m"
end

def draw(grid, label: nil)
  puts label if label
  puts(grid.map.with_index { |row, y|
    row.map.with_index { |val, x|
      _pos = [y, x]
      case val
      when "#", /\d/
        color(val, 32)
      when "."
        # color(val, 38)
        val
      else
        val
      end
    }.join
  })
  puts
  grid
end

def calc_distance(x1, y1, x2, y2)
  [x2 - x1, y2 - y1].map(&:abs).sum
end

input = read_input
grid = input.map(&:chars)

exp_grid = grid.then { expand_rows(_1) }.then { expand_cols(_1) }

galaxies = []
exp_grid.each_with_index do |row, y|
  row.each_with_index do |val, x|
    galaxies << [y, x] if val == "#"
  end
end

shortest = galaxies.combination(2).map { |from, to| calc_distance(*from, *to) }

res = shortest.sum
puts "Answer 11.1: #{res}"

binding.irb if ENV["DEBUG"]

res2 = nil
puts "Answer 11.2: #{res2}"
