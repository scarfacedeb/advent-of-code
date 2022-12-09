require 'set'
require 'debug'

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").map { |l| d, s = l.split(" "); [d.to_sym, s.to_i] }
end

def draw(rope)
  max = rope.flatten.max
  width = [max, 30].max
  height = [max, 30].max
  grid = []

  marks = rope.map.with_index.each_with_object({}) { |(m, i), h| h[m] ||= i.zero? ? 'H' : i }

  width.times do |y|
    row = []
    height.times do |x|
      point = marks[[x, y]]
      point ||= "s" if [x, y] == [0, 0]
      point ||= "."
      row << point
    end
    grid << row
  end
  puts "\n"
  puts grid.map { _1.join("") }.reverse.join("\n")
  puts "\n"
end

DIRS = {
  R: [1, 0],
  L: [-1, 0],
  U: [0, 1],
  D: [0, -1]
}

DELTAS = {
  R: 1,
  L: -1,
  U: 1,
  D: -1
}

def decr_abs(int, sub = 1)
  return 0 if int.zero?
  int > 0 ? int - sub : int + sub
end

def apply_delta(pos, delta)
  pos.map.with_index { _1 + delta[_2] }
end

def calc_distance(head, tail)
  head.map.with_index { _1 - tail[_2] }
end

def move_straight(tail, distance)
  apply_delta(tail, distance.map { _1 > 0 ? _1 - 1 : (_1 < 0 ? _1 + 1 : _1) })
end

def move_diagonal(tail, distance)
  return tail if distance.all? { _1.abs == 1 }

  dx, dy = distance
  if dy.abs > dx.abs
    apply_delta(tail, [dx, decr_abs(dy)])
  elsif dx.abs > dy.abs
    apply_delta(tail, [decr_abs(dx), dy])
  else
    apply_delta(tail, [decr_abs(dx), decr_abs(dy)])
  end
end

def move_tail(head, tail)
  distance = calc_distance(head, tail)
  # puts "#{head} <- #{tail}    =   #{distance}"
  return move_straight(tail, distance) if distance.any? { _1 == 0 }
  move_diagonal(tail, distance)
end

def move(rope, m, visited)
  puts "MOVE: #{m.join}"
  dir, steps = m
  delta = DIRS[dir]

  steps.times do
    # binding.b

    # head = rope.shift
    head = apply_delta(rope.shift, delta)
    top_head = head
    tail = nil
    $new_rope = [head]
    $rope = rope

    rope = rope.map.with_index(1) do |t, idx|
      # puts "T#{idx}: #{t}"
      tail = t
      # head = apply_delta(head, delta)
      tail = move_tail(head, tail)
      # top_head = head if idx.zero?
      # binding.b
      $new_rope << tail
      head = tail
    end

    rope.unshift(top_head)
    # binding.b
    visited << tail
  end
    draw(rope)
  rope
end

moves = read_input
visited = Set.new
rope = 2.times.map { [0, 0] }

moves.each { |m| rope = move(rope, m, visited) }

ans = visited.count

visited = Set.new
rope = 10.times.map { [0, 0] }
moves.each { |m| rope = move(rope, m, visited) }

ans2 = visited.count

puts "Answer 9.1: #{ans}"
puts "Answer 9.2: #{ans2}"
