require 'set'
require 'debug'
require 'tty-cursor'

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").map { |l| d, s = l.split(" "); [d.to_sym, s.to_i] }
end

$drawn_moves = []
TICK = 0.005
GRID_SIZE = 90

def draw(rope, m)
  $drawn_moves << m unless $drawn_moves.last == m

  grid = []
  marks = rope.map.with_index.each_with_object({}) { |(m, i), h| h[m] ||= i.zero? ? 'H' : i }
  marks.merge! $drawn_visited.each_with_object({}) { |m, h| h[m] = '#' }
  marks.transform_keys! { |m| [m[0] + 80, m[1] + 80] }

  print $cursor.restore
  print $cursor.save

  GRID_SIZE.times do |y|
    row = []
    GRID_SIZE.times do |x|
      point = marks[[x, y]]
      point = "#" if $drawn_visited.include?([x, y])
      point ||= "s" if [x, y] == [0, 0]
      point ||= "."
      row << point
    end
    grid << row
  end
  print grid.map { _1.join("") }.reverse.join("\n")
  # print "\n\n\nMOVE: #{$drawn_moves.map(&:join).join(' -> ')}"
  sleep TICK
end

DIRS = {
  R: [1, 0],
  L: [-1, 0],
  U: [0, 1],
  D: [0, -1]
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
  apply_delta(tail, distance.map { decr_abs(_1) })
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
  draw(rope, m)

  dir, steps = m
  delta = DIRS[dir]
  last_drawn_rope = rope

  steps.times do
    head = apply_delta(rope.shift, delta)
    rope = [head] + rope.map { |tail|
      head = move_tail(head, tail)
    }
    visited << head

    # draw(rope, m) unless rope == last_drawn_rope
    last_drawn_rope = rope
  end

  draw(rope, m)
  sleep TICK
  rope
end

$cursor = TTY::Cursor
print $cursor.clear_screen
print $cursor.hide

moves = read_input

# visited = Set.new
# rope = 2.times.map { [0, 0] }
# moves.each { |m| rope = move(rope, m, visited) }
# ans = visited.count

visited = Set.new
$drawn_visited = visited
rope = 10.times.map { [0, 0] }
moves.each { |m| rope = move(rope, m, visited) }

ans2 = visited.count

print "\n\n"
# puts "Answer 9.1: #{ans}"
puts "Answer 9.2: #{ans2}"

print $cursor.show
