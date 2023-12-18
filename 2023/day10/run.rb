require "debug"

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.readlines(ARGV.last || file).map(&:strip)
end

# l, t, r, b
DELTAS = [[-1, 0], [0, 1], [1, 0], [0, -1]].freeze

# | is a vertical pipe connecting north and south.
# - is a horizontal pipe connecting east and west.
# L is a 90-degree bend connecting north and east.
# J is a 90-degree bend connecting north and west.
# 7 is a 90-degree bend connecting south and west.
# F is a 90-degree bend connecting south and east.
# . is ground; there is no pipe in this tile.
DIRS = %i[bottom left top right].freeze
VALID_PIPES = {
  bottom: %w[| 7 F],
  left: %w[- J 7],
  top: %w[| L J],
  right: %w[- L F]
}.transform_values(&:to_set).freeze

def pos_around(pos)
  DELTAS
    .map { pos.zip(_1).map(&:sum) }
    .map { _1.any?(&:negative?) ? nil : _1 }
end

def pos_around!(pos) = pos_around(pos).compact

def pos_dir_around(pos)
  DIRS.zip(pos_around(pos)).to_h
end

def pos_val_around(grid, pos)
  pos_around(pos).compact.map { [_1, grid.dig(*_1)] }
end

def find_point(grid, point)
  grid.each_with_index { |row, y|
    row.each_with_index { |val, x|
      return [y, x] if val == point
    }
  }
end

def color(val, code)
  "\e[#{code}m#{val}\e[0m"
end

def draw(grid, outside: nil, inside: nil, cur: nil)
  outside = (outside || []).map.with_index { |pl, i| pl.to_a.map { [_1, i] } }.reduce(:+).to_h
  inside = (inside || []).map.with_index { |pl, i| pl.to_a.map { [_1, i] } }.reduce(:+).to_h

  puts(grid.map.with_index { |row, y|
    row.map.with_index { |val, x|
      pos = [y, x]
      if pos == cur
        color("X", 33)
      elsif outside[pos]
        color(outside[pos].to_s[0], 31)
      elsif inside[pos]
        color(inside[pos].to_s[0], 32)
      elsif val == "S"
        color(val, 35)
      else
        val
      end
    }.join
  })
  puts
end

input = read_input
grid = input.map(&:chars)

start = find_point(grid, "S")
outlet, inlet =
  start
    .then { pos_dir_around(_1) }
    .compact
    .select { |dir, pos| VALID_PIPES[dir].include?(grid.dig(*pos)) }
    .to_a

FLOW = {
  "|" => { bottom: [:bottom, [-1, 0]], top: [:top, [1, 0]] },
  "-" => { left: [:left, [0, 1]], right: [:right, [0, -1]] },
  "L" => { top: [:left, [0, 1]], right: [:bottom, [-1, 0]] },
  "J" => { left: [:bottom, [-1, 0]], top: [:right, [0, -1]] },
  "7" => { bottom: [:right, [0, -1]], left: [:top, [1, 0]] },
  "F" => { bottom: [:left, [0, 1]], right: [:top, [1, 0]] }
}.freeze

def build_path(grid, outlet, start)
  dir, pos = outlet
  val = grid.dig(*pos)
  path = [[pos, val, dir]]

  until pos == start
    dir, delta = FLOW.dig(val, dir)
    pos = pos.zip(delta).map(&:sum)
    val = grid.dig(*pos)
    path << [pos, val, dir]
  end

  # put S first
  path.unshift path.pop
end

path = build_path(grid, outlet, start)

res = (path.size / 2.0).ceil
puts "Day 10.1: #{res}"

# == PART 2 ==

EXPANSIONS = {
  "." => [
    %w[. . .],
    %w[. . .],
    %w[. . .]
  ],
  "-" => [
    %w[. . .],
    %w[- - -],
    %w[. . .]
  ],
  "|" => [
    %w[. | .],
    %w[. | .],
    %w[. | .]
  ],
  "7" => [
    %w[. . .],
    %w[- 7 .],
    %w[. | .]
  ],
  "J" => [
    %w[. | .],
    %w[- J .],
    %w[. . .]
  ],
  "L" => [
    %w[. | .],
    %w[. L -],
    %w[. . .]
  ],
  "F" => [
    %w[. . .],
    %w[. F -],
    %w[. | .]
  ],
  "S" => [
    %w[. | .],
    %w[. S -],
    %w[. . .]
  ]
}.freeze

path_coords = path.map(&:first).to_set
grounded_grid = grid.map.with_index { |row, y| row.map.with_index { |val, x| path_coords.include?([y, x]) ? val : "." } }

exp_grid = grounded_grid.flat_map { |row| row.map { |val| EXPANSIONS.fetch(val) }.transpose.map(&:flatten) }

ground = exp_grid.map.with_index { |row, y|
  row.filter_map.with_index { |v, x|
    v == "." ? [y, x] : nil
  }
}.flatten(1).to_set

pools = []

def flow(grid, pos, visited)
  # binding.b
  val = grid.dig(*pos)
  return visited unless val == "."
  return visited if visited.include?(pos)

  visited << pos

  around = pos_around!(pos).to_set - visited
  around.reduce(visited) { |agg, nbor|
    flow(grid, nbor, agg)
  }
end

until ground.empty?
  pos = ground.first
  val = exp_grid.dig(*pos)
  visited = Set.new([pos])
  around = pos_around!(pos).to_set

  until around.empty?
    nbor = around.first
    around.delete(nbor)

    if exp_grid.dig(*nbor) == "."
      visited << nbor
      around += (pos_around!(nbor).to_set - visited)
    end
  end

  # around.reduce(visited) do |agg, nbor|
  #   flow(grid, nbor, agg)
  # end

  # visited = flow(exp_grid, ground.first, Set.new)
  pools << visited
  ground -= visited
end

inside = []
outside = []

BORDER_Y = exp_grid.size - 1
BORDER_X = exp_grid.first.size - 1

def bordering?(pool)
  pool.any? { |y, x| y == 0 || x == 0 || y == BORDER_Y || x == BORDER_X }
end

# LEAKS = %w[
#   7F JL J7 LF
# ].freeze

# def forward(_grid, _path, cur)
#   pos, val, dir = cur
# end

# def leaks_to_outside?(grid, _path, pair)
#   # before_idx, after_idx = pair.map { |pos, _val| path.index { _1.first == pos } }
#   case pair.map(&:first).join
#   when "7F"
#     finished = false
#     positions = pair.map(&:last)
#     outside = false

#     until finished
#       positions = positions.map { _1.zip([1, 0]).reduce(&:+) }
#       values = positions.reject { _1.any?(&:negative) }.map { grid.dig(*_1) }
#       outside = values.all? { _1 != "." } || bordering?(positions)
#       finished = outside || values
#     end

#     outside
#   end

#   false
# end

# def leaking?(grid, path, pool)
#   around_pos = pool.map { |pos| pos_around!(pos).to_set }.reduce(:+) - pool
#   around_val = around_pos.map { grid.dig(*_1) }
#   around = around_pos.zip(around_val)

#   around.repeated_permutation(2).any? { |pair|
#     diff = pair.map(&:first).reduce(&:zip).map { _2 - _1 }
#     neighbours = [[0, 1], [1, 0]].include?(diff)
#     neighbours &&
#       LEAKS.include?(pair.map(&:last).join) &&
#       leaks_to_outside?(grid, path, pair)
#   }
#   # %w[J F L 7].any? { around_val.include?(_1) }
# end

pools.each do |pl|
  if bordering?(pl)
    outside << pl
  else
    inside << pl
  end
end

draw(exp_grid, outside:, inside:)

counts = inside.map { |pl|
  grouped = pl.reduce({}) { |h, pos|
    h[pos[0]] ||= []; h[pos[0]] << pos[1]; h
  }.transform_values(&:sort)

  inside_count = grouped.to_a.each_cons(3)
    .select { (_1[0][0] + 1) == _1[1][0] && (_1[0][0] + 2) == _1[2][0] }
    .map { |g|
    intr = g.map(&:last).reduce(&:&).sort
    uniq = intr.each_cons(3).select { (_1[0] + 1) == _1[1] && (_1[0] + 2) == _1[2] }.size / 3; [g[1][0] / 3, uniq]
  }.to_h.values.sum

  inside_count
}

res2 = counts.sum
# bordering, pools = pools.partition { |pool|
#   pool.any? { |y, x| y == 0 || x == 0 || y == border_y || x == border_x }
# }

# draw grid, outside: bordering, inside: pools

# | is a vertical pipe connecting north and south.
# - is a horizontal pipe connecting east and west.
# L is a 90-degree bend connecting north and east.
# J is a 90-degree bend connecting north and west.
# 7 is a 90-degree bend connecting south and west.
# F is a 90-degree bend connecting south and east.

# binding.b

# inside = []
# outside = []
# flip_y = false
# flip_x = false
# angle = 0

# DEBUG = ENV["DEBUG"]&.to_i || 1_000_000

# path.each_with_index do |seg, i|
#   pos, val, dir = seg
#   # prev_val = grid.dig(*path[i - 1]) if i > 0

#   # around = pos_val_around(grid, pos).filter_map { _1 if _2 == "." }

#   # DELTAS = [[-1, 0], [0, 1], [1, 0], [0, -1]].freeze
#   top, right, bottom, left = pos_around(pos)

#   binding.b if i >= DEBUG
#   # case [prev_val, val].join
#   case [dir.to_s, val]
#   when %w[bottom S]
#     out_around = [top, left]
#     in_around = [bottom]
#   when %w[left -]
#     out_around = [top]
#     in_around = [bottom]
#   when %w[right -]
#     out_around = [bottom]
#     in_around = [top]
#     # out_around, in_around = in_around, out_around if (angle / 90)
#   when %w[top |]
#     out_around = [right]
#     in_around = [left]
#     # out_around, in_around = in_around, out_around if flip_x
#   when %w[bottom |]
#     out_around = [left]
#     in_around = [right]
#   when %w[left 7]
#     out_around = [top, right]
#     in_around = []
#     angle += 90
#   when %w[bottom 7]
#     out_around = [top, right]
#     in_around = []
#     angle -= 90
#   when %w[top J]
#     out_around = [right, bottom]
#     in_around = []
#     angle += 90
#   when %w[left J]
#     out_around = []
#     in_around = [right, bottom]
#     angle -= 90
#   when %w[right L]
#     out_around = [bottom, left]
#     in_around = []
#     angle += 90
#   when %w[top L]
#     out_around = []
#     in_around = [bottom, left]
#     angle -= 90
#   when %w[bottom F]
#     out_around = [top, left]
#     in_around = []
#     angle += 90
#   when %w[right F]
#     out_around = []
#     in_around = [top, left]
#     angle -= 90
#   else
#     binding.b
#   end

#   angle = 0 if angle == 360
#   out_around = out_around.compact.select { grid.dig(*_1) == "." }
#   in_around = in_around.compact.select { grid.dig(*_1) == "." }

#   puts "OUT: #{out_around}"
#   puts "IN: #{in_around}"
#   # p around
#   # binding.b if i > 11

#   out_around.each do |gpos|
#     around_ground = pos_around!(gpos) << gpos
#     pools = outside.select { |pl| pl.intersect?(around_ground) }
#     if pools.size > 1
#       outside << (pools.reduce(:+) << gpos)
#       pools.each { outside.delete(_1) }
#     elsif pools.size == 1
#       pools.first << gpos
#     else
#       outside << [gpos].to_set
#     end
#   end

#   in_around.each do |gpos|
#     around_ground = pos_around!(gpos) << gpos
#     pools = inside.select { |pl| pl.intersect?(around_ground) }
#     if pools.size > 1
#       inside << (pools.reduce(:+) << gpos)
#       pools.each { inside.delete(_1) }
#     elsif pools.size == 1
#       pools.first << gpos
#     else
#       inside << [gpos].to_set
#     end
#   end

#   # all_outside = outside.flat_map(&:to_a).to_set
#   # inside = inside.reject { |pl| pl.intersect?(all_outside) }

#   puts i
#   draw grid, outside:, inside:, cur: pos
# end

# draw grid, outside:, inside:

puts "Day 10.2: #{res2}"

binding.irb
