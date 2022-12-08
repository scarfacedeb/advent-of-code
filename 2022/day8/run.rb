def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").map { _1.chars.map(&:to_i) }
end

def print(mx)
  puts mx.map(&:join)
end

def line_coords(i, max_i)
  [0.upto(i-1), (i+1).upto(max_i-1)]
end

def find_lines(mx, y, x)
  cols_before, cols_after = line_coords(y, mx.size).map { |l| l.map { mx.dig(_1, x) } }
  rows_before, rows_after = line_coords(x, mx.first.size).map { |l| l.map { mx.dig(y, _1) } }
  [cols_before.reverse, cols_after, rows_before.reverse, rows_after]
end

def hidden?(lines, val)
  lines.all? { |l| l.any? { _1 >= val } }
end

def score(lines, val)
  lines.map { |l|
    idx = l.index { _1 >= val }
    idx ? idx + 1 : l.size
  }.reduce(&:*)
end

mx = read_input

trees = mx.map.with_index.to_a[1..-2].map { |row, y|
  row.map.with_index.to_a[1..-2].map { |val, x|
    lines = find_lines(mx, y, x)
    [[y, x], !hidden?(lines, val), score(lines, val)]
  }
}.flatten(1)

outside = (mx.size + mx.first.size) * 2 - 4
ans = trees.count { _2 } + outside
puts "Answer 8.1: #{ans}"

ans2 = trees.sort_by(&:last).last.last
puts "Answer 8.2: #{ans2}"
