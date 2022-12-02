require "benchmark"
require "debug"

def read_input(file = nil)
  file ||= $all ? "input.txt" : "example.txt"
  input = File.read(ARGV.last || file).split(/--- scanner \d+ ---/).tap(&:shift)
  input.map { |s| s.strip.lines(chomp: true).map { _1.split(",").map(&:to_i) } }
end

def sin(deg) = Math.sin(deg * Math::PI / 180)
def cos(deg) = Math.cos(deg * Math::PI / 180)

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

def map_rotate(coord)
  ROTATIONS.map { [rotate(coord, _1), _1] }
end

TRANSFORMATIONS =
  [1,2,3]
    .then(&method(:map_rotate))
    .flat_map { |d, deg| PERMUTATIONS.map { [multiply(d, _1), deg, _1] } }
    .group_by(&:first)
    .transform_values { _1.map { |t| t.tap(&:shift) } }
    .values
    .map(&:first)
    .uniq

def transform(coord)
  TRANSFORMATIONS.map { |rot, mut| multiply(map_rotate(coord, rot), mut) }
end

def map_transform(scanner)
  scanner.map(&method(:transform)).transpose
end

Delta = Struct.new(:d, :rotated, :rel, :abs, :mut, keyword_init: true)

def calc_deltas(scanner)
  scanner
    .then(&method(:map_transform))
    .flat_map { |points|
      points.map.with_index.to_a.combination(2).map {
        Delta.new(
          d: diff(_1[0], _2[0]),
          rotated: [_1[0], _2[1]],
          rel: [scanner[_1[1]], scanner[_2[1]]],
          # abs: [base[_1[1]], base[_2[1]]],
          mut: nil
        )
      }
    }
    .flat_map { |delta|
      PERMUTATIONS.map { |mut|
        delta.dup.tap {
          _1.d = multiply(_1.d, mut)
          _1.mut = mut
        }
      }
    }
    .uniq
end

# For scanner 0
def create_index(scanner)
  calc_deltas(scanner).each { _1.abs = _1.rel }.group_by(&:d)
end

# def calc_deltas(scanner)
#   scanner
#     .then(&method(:map_rotate))
#     .flat_map { |points| points.combination(2).map { [diff(_1, _2), [_1, _2]] } }
#     .flat_map { |d, points| PERMUTATIONS.map { |mut| [multiply(d, mut), [points, mut]] } }
#     .uniq
#     .to_h
#   # .reduce({}) { |acc, (d, points)| acc[d] ||= []; acc[d] << points; acc }
# end

def calc_scanner_pos(delta)
  base_point, other_point, mut = delta.abs[0], delta.rel[0], delta.mut
  inverse(diff(base_point, multiply(mut, other_point)))
end

def relative_to_abs(scanner, scanner_pos, delta)
  mut = find_mut(scanner_pos, delta)
  scanner.map { inverse(diff(scanner_pos, multiply(_1, mut))) }
end

def find_mut(scanner_pos, delta)
  rel, abs = delta.rel[0], delta.abs[0]
  PERMUTATIONS.map { |mut|
    [multiply(rel, mut), mut]
  }.map { [inverse(diff(scanner_pos, _1)), _2] }.find { _1[0] == abs }.last
end

def find_common(deltas_index, deltas, other_deltas)
  common_delta_values = deltas.map(&:d) & other_deltas.map(&:d)
  return [[], nil, nil] if common_delta_values.empty?

  other_deltas_index = other_deltas.group_by(&:d)

  common_other_deltas = common_delta_values.flat_map { |d|
    abs_points = deltas_index[d][0].abs # FIXME: Take first matching
    other_deltas_index[d].each { _1.abs = abs_points }
  }.uniq

  common_points = common_other_deltas.flat_map(&:abs).uniq
  # scanner_pos = calc_scanner_pos(common_other_deltas[0])

  base_point, other_point, mut = common_other_deltas[0].abs[0], common_other_deltas[0].rel[0],
common_other_deltas[0].mut
  scanner_pos = inverse(diff(base_point, multiply(mut, other_point)))
  binding.b

  [common_points, scanner_pos, common_other_deltas]
end

############

scanners = read_input

deltas_index = create_index(scanners[0])

all_deltas = scanners.map(&method(:calc_deltas))

found, scanner_pos, common_other_deltas = find_common(deltas_index, all_deltas[0], all_deltas[1])

scanner_abs = relative_to_abs(scanners[1], scanner_pos, common_other_deltas[0])

deltas_index = create_index(scanner_abs).merge(deltas_index)

# deltas_index2 = common_deltas.map { [_1.d, _1] }.to_h.merge(deltas_index)
# deltas_index = deltas_index2

scans = 0.upto(4).to_a.combination(2).to_a - [[0, 1]]

from, to = 1, 4
found, scanner_pos, common_other_deltas = find_common(deltas_index, all_deltas[from], all_deltas[to])
puts "#{from}:#{to}: #{found.count}"

scanner_abs = relative_to_abs(scanners[to], scanner_pos, common_other_deltas[0])

# binding.b

# deltas_index = create_index(scanner_abs).merge(deltas_index)

# res =
#   scans.map { |from, to|
#     found, scanner_pos, common_other_deltas = find_common(deltas_index, all_deltas[from], all_deltas[to])
#     puts "#{from}:#{to}: #{found.count}"
#     # next if
#     # scanner_abs2 = relative_to_abs(scanners[4], scanner_pos2, common_other_deltas2[0])
#   }

# binding.b

p found
p scanner_pos

p found2
p scanner_pos2

puts "Answer 19.1: #{found.count} + #{found2.count}"

# binding.b
