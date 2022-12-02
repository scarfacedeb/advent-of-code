require "benchmark"
require "debug"
require "ostruct"

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
ROTATIONS = [[0, 0, 0]] + DEGREES.permutation(3).to_a
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

def gen_rotations(coord)
  ROTATIONS.map { rotate(coord, _1) }
end

def map_rotate(scanner)
  scanner.map { gen_rotations(_1) }.transpose
end

Delta = Struct.new(:d, :comb, :orig, :base, :mut, keyword_init: true)

def create_index(scanner, base)
  scanner
    .then(&method(:map_rotate))
    .flat_map { |points|
      points.map.with_index.to_a.combination(2).map {
        Delta.new(
          d: diff(_1[0], _2[0]),
          comb: [_1[0], _2[1]],
          orig: [scanner[_1[1]], scanner[_2[1]]],
          base: [base[_1[1]], base[_2[1]]],
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

def calc_deltas(scanner)
  scanner
    .then(&method(:map_rotate))
    .flat_map { |points| points.combination(2).map { [diff(_1, _2), [_1, _2]] } }
    .flat_map { |d, points| PERMUTATIONS.map { |mut| [multiply(d, mut), [points, mut]] } }
    .uniq
    .to_h
  # .reduce({}) { |acc, (d, points)| acc[d] ||= []; acc[d] << points; acc }
end

def calc_scanner_pos(base_point, other_point, mut)
  inverse(diff(base_point, multiply(mut, other_point)))
end

def find_common(deltas_index, deltas, other_deltas, deltas_index2 = {})
  common_deltas = (deltas.keys & other_deltas.keys)
  common = common_deltas.map { [_1, deltas_index[_1][0], deltas_index2[_1][0], other_deltas[_1]] }.uniq
  common_points = common.flat_map { _1[1] || _1[2] }.compact.uniq
  delta, base_points, base_points2, other_points = common.first

  base_point = base_points ? base_points[0] : base_points2[0]
  (other_point,), mut = other_points

  # exp = [68,-1246,-43]

  # scanner_pos = diff(base_point, multiply(mut.map { -_1 }, other_point ))
  scanner_pos = calc_scanner_pos(base_point, other_point, mut)

  binding.b

  [common_points, scanner_pos, mut]
end

def reposition(scanner, scanner_pos, mut)
  mut = inverse(mut)
  scanner.map { inverse(diff(scanner_pos, multiply(_1, mut))) }
end

############

scanners = read_input

deltas_index = create_index(scanners.first, scanners.first)

binding.b

all_deltas = scanners.map(&method(:calc_deltas))

found, scanner_pos, mut = find_common(deltas_index, all_deltas[0], all_deltas[1])

repositioned = reposition(scanners[1], scanner_pos, mut)
deltas_index2 = create_index(repositioned)

binding.b
# deltas_index = deltas_index2.merge(deltas_index)

# all_deltas[1]scanner_pos

found2, scanner_pos2, mut2 = find_common(deltas_index, all_deltas[1], all_deltas[4], deltas_index2)

p found
p scanner_pos

p found2
p scanner_pos2

puts "Answer 19.1: #{found.count}"

binding.b
