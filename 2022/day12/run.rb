require "debug"

PEAK = 26
CHARS = ("a".."z").map.with_index.to_h.merge("S" => -1, "E" => PEAK)
DELTAS = [[1, 0], [-1, 0], [0, 1], [0, -1]]

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").map(&:chars)
end

def move(mx, pos, value, visited = {}, path = [], cost = 0)
  visited[pos] = cost
  cost += 1
  path += [pos]

  return path if value == PEAK

  DELTAS
    .map { pos.zip(_1).map(&:sum) }
    .reject { _1.any?(&:negative?) || (visited[_1] && visited[_1] <= cost) }
    .map { [_1, mx.dig(*_1)] }
    .select { |_, v| v && (v - value) <= 1 }
    .map { move(mx, _1, _2, visited, path, cost) }
    .compact
    .min
end

chars = read_input
mx = chars.map { |l| l.map { CHARS[_1] } }

pos = mx.map.with_index { |row, y| [y, row.find_index { |val| val == -1 }] }.find { _2 }

path = move(mx, pos, mx.dig(*pos))
ans = path.size - 1

puts "Answer 12.1: #{ans}"
puts path.map { chars.dig(*_1) }.join

last_a_pos = path.map.with_index { [chars.dig(*_1), _2] }.select { |v, _| v == "a" }.last.last
ans2 = ans - last_a_pos

puts "Answer 12.2: #{ans2}"
