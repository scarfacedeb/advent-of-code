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


DEGREES = [0, 90, 180, 270]
TRIG = DEGREES.map { [_1, [sin(_1), cos(_1)]] }.to_h
ROTATIONS = DEGREES.permutation(3).to_a

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

scanners = read_input

PERMUTATIONS = [1,-1].repeated_permutation(3).to_a

def create_index(scanner)
  deltas = map_rotate(scanner).flat_map { |points|
    points.map.with_index.to_a.combination(2).map {
      [
        diff(_1[0], _2[0]),
        # [_1[0], _2[0]]
        [scanner[_1[1]], scanner[_2[1]]]
      ]
    }
  }.uniq

  deltas.flat_map { |d, points|
    PERMUTATIONS.map { [multiply(d, _1), points] }
  }.to_h
end

# deltas1 = scanners[1].combination(2).map { [diff(_1, _2).then { |x,y,z| [-x, y, -z] }, [_1, _2]] }.to_h
def calc_deltas(scanner)
  scanner
    .then(&method(:map_rotate))
    .flat_map { |points| points.combination(2).map { diff(_1, _2) } }
    .flat_map { |d| PERMUTATIONS.map { multiply(d, _1) } }
    .uniq
end

def find_common(deltas_index, deltas, other_deltas)
  (deltas & other_deltas).flat_map { deltas_index[_1] }.uniq    #
end

deltas_index = create_index(scanners.first)

all_deltas = scanners.map(&method(:calc_deltas))

found = find_common(deltas_index, all_deltas[0], all_deltas[1])

p found
puts "Answer 19.1: #{found.count}"

binding.b


 scanner_pos = inverse(diff(base_point, multiply(mut, other_point)))


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
