require "debug" if ENV["DEBUG"]

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n")
end

def empty_indices(rows)
  rows.filter_map.with_index { |row, y| row.all? { _1 == "." } ? y : nil }
end

def expand(empty)
  empty.map.with_index { |coord, i| coord + HUBBLE * i }
end

def calc_distance(x1, y1, x2, y2)
  [x2 - x1, y2 - y1].map(&:abs).sum
end

input = read_input
grid = input.map(&:chars)

galaxies = []
grid.each_with_index do |row, y|
  row.each_with_index do |val, x|
    galaxies << [y, x] if val == "#"
  end
end

HUBBLE = 1_000_000 - 1

empty_rows = empty_indices(grid).then { expand(_1) }
empty_cols = empty_indices(grid.transpose).then { expand(_1) }

galaxies = empty_rows.reduce(galaxies) { |agg, empty_y|
  agg.map { |y, x| y > empty_y ? [y + HUBBLE, x] : [y, x] }
}

galaxies = empty_cols.reduce(galaxies) { |agg, empty_x|
  agg.map { |y, x| x > empty_x ? [y, x + HUBBLE] : [y, x] }
}

shortest = galaxies.combination(2).map { |from, to| calc_distance(*from, *to) }

res = shortest.sum
puts "Answer 11.2: #{res}"

binding.irb if ENV["DEBUG"]
