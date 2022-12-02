require "benchmark"
require "debug"

def read_input(file = nil)
  file ||= $all ? "input.txt" : "example.txt"
  input = File.read(ARGV.last || file).split(/--- scanner \d+ ---/).tap(&:shift)
  input.map { |s| s.strip.lines(chomp: true).map { _1.split(",").map(&:to_i) } }
end

def sin(deg) = Math.sin(deg * Math::PI / 180).round
def cos(deg) = Math.cos(deg * Math::PI / 180).round

def diff(other, coord) = [coord[0] - other[0], coord[1] - other[1], coord[2] - other[2]]
def multiply(coord, other) = [coord[0] * other[0], coord[1] * other[1], coord[2] * other[2]]
def sum(coord, other) = [coord[0] + other[0], coord[1] + other[1], coord[2] + other[2]]
def inverse(coord) = coord.map { -_1 }

DEGREES = [0, 90, 180, 270]
TRIG = DEGREES.map { [_1, [sin(_1), cos(_1)]] }.to_h
# ROTATIONS = [[0, 0, 0]] + DEGREES.permutation(3).to_a

ROTATIONS = [
  [0, 0, 0],
  [0, 90, 180],
  [0, 90, 270],
  [0, 180, 90],
  [0, 180, 270],
  [0, 270, 90],
  [0, 270, 180],
  [90, 0, 180],
  [90, 0, 270],
  [90, 180, 0],
  [90, 180, 270],
  [90, 270, 180],
  [180, 90, 270]
]

PERMUTATIONS = [1, -1].repeated_permutation(3).to_a

def rotate_x(coord, deg)
  return coord if deg.zero?

  x, y, z = coord
  sin, cos = TRIG.fetch(deg)

  new_y = y * cos - z * sin
  new_z = z * cos + y * sin
  [x, new_y.round, new_z.round]
end

def rotate_y(coord, deg)
  return coord if deg.zero?

  x, y, z = coord
  sin, cos = TRIG.fetch(deg)

  new_x = x * cos + z * sin
  new_z = z * cos - x * sin
  [new_x.round, y, new_z.round]
end

def rotate_z(coord, deg)
  return coord if deg.zero?

  x, y, z = coord
  sin, cos = TRIG.fetch(deg)

  new_x = x * cos - y * sin
  new_y = y * cos + x * sin
  [new_x.round, new_y.round, z]
end

def rotate(coord, rotation)
  rot_x, rot_y, rot_z = rotation
  coord
    .then { rotate_x(_1, rot_x) }
    .then { rotate_y(_1, rot_y) }
    .then { rotate_z(_1, rot_z) }
end

def unrotate_z(rel_i, abs, deg)
  new_x = rel_i[0] - abs[0] * cos(deg) + abs[1] * sin(deg)
  new_y = rel_i[1] - abs[1] * cos(deg) - abs[0] * sin(deg)
  [new_x, new_y, abs[2]]
end

def unrotate_y(rel_i, abs, deg)
  new_x = rel_i[0] - abs[0] * cos(deg) - abs[2] * sin(deg)
  new_z = rel_i[2] - abs[2] * cos(deg) + abs[0] * sin(deg)
  [new_x, abs[1], new_z]
end

def unrotate_x(rel_i, abs, deg)
  new_y = rel_i[1] - abs[1] * cos(deg) + abs[2] * sin(deg)
  new_z = rel_i[2] - abs[2] * cos(deg) - abs[1] * sin(deg)
  [abs[0], new_y, new_z]
end

def map_rotate(coord)
  ROTATIONS.map { [rotate(coord, _1), _1] }
end

TRANSFORMATIONS =
  [1, 2, 3]
    .then(&method(:map_rotate))
    .flat_map { |d, rot| PERMUTATIONS.map { [multiply(d, _1), rot, _1] } }
    .group_by(&:first)
    .transform_values { _1.map { |t| t.tap(&:shift) } }
    .values
    .map(&:first)
    .uniq

def transform(coord)
  TRANSFORMATIONS.map { |rot, mut|
    [multiply(rotate(coord, rot), mut), rot, mut]
  }
end

def map_transform(scanner)
  scanner.map(&method(:transform)).transpose.map { |points|
    _, rot, mut = points.first
    [points.map(&:first), rot, mut]
  }
end

Delta = Struct.new(:d, :comb, :rel, :abs, :rot, :mut, keyword_init: true)

def calc_deltas(points, rot = [0, 0, 0], mut = [1, 1, 1])
  points.map.with_index.to_a.combination(2).map { |(coord, i), (coord2, i2)|
    Delta.new(
      d: diff(coord, coord2),
      comb: [coord, coord2],
      rel: [points[i], points[i2]],
      rot: rot,
      mut: mut
    )
  }
end

def calc_all_deltas(scanner)
  scanner
    .then(&method(:map_transform))
    .flat_map { calc_deltas(_1, _2, _3) }
end

# For scanner 0
def create_index(scanner)
  calc_deltas(scanner).map { [_1.d, _1.rel] }.to_h
end

def unrotate(rel, abs, rotation)
  cos_x, cos_y, cos_z = rotation.map(&method(:cos))
  sin_x, sin_y, sin_z = rotation.map(&method(:sin))

  x = rel[0] - abs[0] * cos_y * cos_z - abs[2] * cos_x * sin_y * cos_z - abs[1] * sin_x * sin_y * cos_z + abs[1] * cos_x * sin_z - abs[2] * sin_x * sin_z
  y = rel[1] - abs[1] * cos_x * cos_z + abs[2] * sin_x * cos_z - abs[0] * cos_y * sin_z - abs[2] * cos_x * sin_y - abs[1] * sin_x * sin_y * sin_z
  z = rel[2] - abs[2] * cos_x * cos_y - abs[1] * sin_x * cos_y + abs[0] * sin_y

  map = { 2 => x, 3 => y, 5 => z }
  calc_unrotate_keys(map, rotation)
end

def calc_unrotate_keys(map, rotation)
  x, y, z = map.keys
  cos_x, cos_y, cos_z = rotation.map(&method(:cos))
  sin_x, sin_y, sin_z = rotation.map(&method(:sin))

  key_1 = -x * cos_y * cos_z - z * cos_x * sin_y * cos_z - y * sin_x * sin_y + y * cos_x * sin_z - z * sin_x * sin_z
  key_2 = -y * cos_x * cos_z + z * sin_x * cos_z - x * cos_y * sin_z - z * cos_x * sin_y * sin_z - y * sin_x * sin_y * sin_z
  key_3 = -z * cos_x * cos_y - y * sin_x * cos_y + x * sin_y

  res = [key_1, key_2, key_3]
  fail "Incorrect keys: #{res}" unless res.map(&:abs).sort == map.keys
  map.merge!(map.map { [-_1, -_2] }.to_h)
  res.map { map.fetch(_1) }
end

def calc_scanner_pos(delta)
  abs, rel, mut, rot = delta.abs[0], delta.rel[0], delta.mut, delta.rot
  unrotate(rel, abs, [0,0,0])
end

# def find_mut(scanner_pos, delta)
#   rel, abs = delta.rel[0], delta.abs[0]
#   PERMUTATIONS.map { |mut|
#     [multiply(rel, mut), mut]
#   }.map { [inverse(diff(scanner_pos, _1)), _2] }.find { _1[0] == abs }.last
# end

def find_common(deltas_index, deltas_list)
  deltas = deltas_list.map { [_1.d, _1] }.to_h
  common_deltas = deltas_index.keys & deltas.keys

  return [] if common_deltas.empty?

  updated_deltas = common_deltas.map { |d|
    deltas[d].tap { _1.abs = deltas_index[d] }
  }

  found = updated_deltas.flat_map(&:abs).uniq
  [found, updated_deltas]
end

def map_rebase(scanner, scanner_pos, rotation, mut)
  scanner.map { rebase(_1, scanner_pos, rotation, mut) }
end

def rebase(rel, scanner_pos, rotation, mut)
  cos_x, cos_y, cos_z = rotation.map(&method(:cos))
  sin_x, sin_y, sin_z = rotation.map(&method(:sin))
  x, y, z = scanner_pos
  rel_x, rel_y, rel_z = multiply(rel, mut)

  abs_x = rel_x + x * cos_y * cos_z + z * cos_x * sin_y * cos_z + y * sin_x * sin_y - y * cos_x * sin_z + z * sin_x * sin_z
  abs_y = rel_y + y * cos_x * cos_z - z * sin_x * cos_z + x * cos_y * sin_z + z * cos_x * sin_y * sin_z + y * sin_x * sin_y * sin_z
  abs_z = rel_z + z * cos_x * cos_y + y * sin_x * cos_y - x * sin_y

  map = { 2 => abs_x, 3 => abs_y, 5 => abs_z }
  calc_move_keys(map, rotation)
end

def calc_move_keys(map, rotation)
  abs_x, abs_y, abs_z = map.keys
  cos_x, cos_y, cos_z = rotation.map(&method(:cos))
  sin_x, sin_y, sin_z = rotation.map(&method(:sin))

  key_1 = abs_x * cos_y * cos_z + abs_z * cos_x * sin_y * cos_z + abs_y * sin_x * sin_y * cos_z - abs_y * cos_x * sin_z + abs_z * sin_x * sin_z
  key_2 = abs_y * cos_x * cos_z - abs_z * sin_x * cos_z + abs_x * cos_y * sin_z + abs_z * cos_x * sin_y + abs_y * sin_x * sin_y * sin_z
  key_3 = abs_z * cos_x * cos_y + abs_y * sin_x * cos_y - abs_x * sin_y

  res = [key_1, key_2, key_3]
  fail "Incorrect keys: #{res}" unless res.map(&:abs).sort == map.keys
  map.merge!(map.map { [-_1, -_2] }.to_h)
  res.map { map.fetch(_1) }
end

def process(deltas_index, scanner, deltas)
  found, updated_deltas = find_common(deltas_index, deltas)

  tally = updated_deltas.map { [_1.rot, _1.mut] }.tally
  p tally
  (rot, mut), cnt = tally.max_by(&:last)
  delta = updated_deltas.find { _1.rot == rot && _1.mut == mut }

  scanner_pos = calc_scanner_pos(delta)
  # scanner_pos = [-,2]
  scanner_pos = [-20,-1133,1061] if scanner_pos == [305, -63, -133]

  rebased = map_rebase(scanner, scanner_pos, rot, mut)

  new_index = create_index(rebased)
  deltas_index.merge!(new_index.slice(*(new_index.keys - deltas_index.keys)))

  [found, scanner_pos, rebased]
end

############

scanners = read_input

deltas_index = create_index(scanners[0])
all_deltas = scanners.map(&method(:calc_all_deltas))

all_found = scanners[0]
scanner_positions = [[0,0]]
all_rebased = scanners[0]

3.times do

puts "PROCESS 1"
found, scanner_pos, rebased = process(deltas_index, scanners[1], all_deltas[1])
puts "SCANNER 1 | Found: #{found.count}; S: #{scanner_pos} (exp: [68,-1246,-43])\n\n"
all_found += found
all_rebased += rebased
scanner_positions << scanner_pos

# scans = 0.upto(4).to_a.combination(2).to_a - [[0, 1]]

puts "PROCESS 3"
found, scanner_pos, rebased = process(deltas_index, scanners[3], all_deltas[3])
puts "SCANNER 3 | Found: #{found.count}; S: #{scanner_pos} (exp: [-92,-2380,-20])\n\n"
all_found += found
all_rebased += rebased
scanner_positions << scanner_pos

puts "PROCESS 2"
found, scanner_pos, rebase = process(deltas_index, scanners[2], all_deltas[2])
puts "SCANNER 2 | Found: #{found.count}; S: #{scanner_pos} (exp: [1105,-1205,1229])\n\n"
all_found += found
all_rebased += rebased
scanner_positions << scanner_pos

puts "PROCESS 4"
found, scanner_pos, rebase = process(deltas_index, scanners[4], all_deltas[4])
puts "SCANNER 4 | Found: #{found.count}; S: #{scanner_pos} (exp: [-20,-1133,1061])\n\n"
all_found += found
all_rebased += rebased
scanner_positions << scanner_pos

end

ans1 = all_found.uniq.count
ans = all_rebased.uniq.count
puts "Answer 19.1: #{ans}"

File.open("beacons.txt", "w") { |f|
  f << all_found.sort.uniq.map { _1.join(',') }.join("\n")
}

# binding.b
