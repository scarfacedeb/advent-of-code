require "benchmark"
require "set"

def read_input
  file = $all ? "input.txt" : "example.txt"
  input = File.read(ARGV.last || file).split("\n")
  input.map { _1.chars.map(&:to_i) }
end

levels = read_input

levels = 5.times
  .map { |t| levels.map { |row| row.map { |col| ncol = col + t; ncol > 9 ? (ncol % 9) : ncol } } }
  .reduce { |acc, m| acc.zip(m).map(&:flatten) }

levels = 5.times
  .map { |t| levels.map { |row| row.map { |col| ncol = col + t; ncol > 9 ? (ncol % 9) : ncol } } }
  .reduce(&:+)

# File.write "example2_2.txt", levels.map { _1.join() }.join("\n")

ADJACENT = [
  [-1,0], [0, -1], [1,0], [0,1]
]
ROWS = levels.count
MAX_POS = ROWS - 1

min_costs = Hash.new { |h, k| h[k] = 999_999_999_999 }
min_costs[[0, 0]] = 0

def shift(set)
  el = set.first
  set.delete(el)
  el
end

unvisited = Set.new [[0,0]]

until unvisited.empty?
  pos = shift(unvisited)
  # puts "Left: #{pos} => #{unvisited.count} #{min_costs[[MAX_POS, MAX_POS]]}"

  adjacent = ADJACENT.map { pos.zip(_1).map(&:sum) }.reject { _1 < 0 || _2 < 0 || _1 > MAX_POS || _2 > MAX_POS }
  adjacent.each do |adj|
    risk = levels.dig(*adj) + min_costs[pos]

    if risk < min_costs[adj]
      min_costs[adj] = risk
      # unvisited << adj if risk < min_costs[[MAX_POS, MAX_POS]]
      unvisited << adj
    end
  end
end

ans = min_costs[[MAX_POS, MAX_POS]]
puts "Answer 15.1: #{ans}"
