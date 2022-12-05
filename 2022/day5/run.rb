def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n")
end

def move(stacks, m, order = nil)
  cnt, from, to = m
  stacks[from].shift(cnt).then { stacks[to].unshift(*(order == :stack ? _1.reverse : _1)) }
end

raw_stack, *raw_moves = read_input.slice_before(/move/).to_a
stacks = raw_stack.tap { _1.pop(2) }.map { _1.chars[(1.._1.length).step(4)] }.transpose.map { |s| s.reject { _1 == " " } }
stacks2 = stacks.map(&:dup)
moves = raw_moves.flatten.map { |m| m.match(/move (\d+) from (\d+) to (\d+)/) { [_1[1].to_i, _1[2].to_i - 1, _1[3].to_i - 1] } }

moves.each { move(stacks, _1, :stack) }

ans = stacks.map(&:first).join
puts "Answer 5.1: #{ans}"

moves.each { move(stacks2, _1) }
ans2 = stacks2.map(&:first).join

puts "Answer 5.2: #{ans2}"
