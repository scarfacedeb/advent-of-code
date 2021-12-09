require 'benchmark'
require 'set'
# require 'byebug'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file).split("\n")
end

# p Benchmark.measure {
hmap = read_input.map { _1.chars.map(&:to_i) }
last_row = hmap.size - 1
last_col = hmap.first.size - 1 # rows x cols

points =
  hmap.map.with_index do |row, i|
    row.map.with_index do |col, j|
      adjacent = [
        (hmap[i - 1][j] if i > 0),
        (row[j + 1] if j < last_col),
        (hmap[i + 1][j] if i < last_row),
        (row[j - 1] if j > 0)
      ]

      [adjacent, [i, j], col]
    end
  end

lowest = points.flatten(1).select { |adj, _, col| adj.compact.min > col }
ans = lowest.map(&:last).sum { _1 + 1 }

puts "Answer 9.1: #{ans}"

def flows(points, basin, i, j)
  return basin if basin.include?([i, j])

  adj, _pos, num = points[i][j]
  t, r, b, l = adj

  basin << [i, j]
  basin = flows(points, basin, i - 1, j) if t && t != 9
  basin = flows(points, basin, i, j + 1) if r && r != 9
  basin = flows(points, basin, i + 1, j) if b && b != 9
  basin = flows(points, basin, i, j - 1) if l && l != 9
  basin
end

basins = lowest.map { |_, pos, _| flows(points, Set.new, *pos) }
ans2 = basins.map(&:size).max(3).reduce(:*)

puts "Answer 9.2: #{ans2}"
# }.total * 1000
