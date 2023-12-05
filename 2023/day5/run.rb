require "debug"

def read_input
  File.readlines(ENV["FULL"] == "1" ? "input.txt" : "example.txt").map(&:strip)
end

def parse(input)
  seeds = input.shift.split.tap(&:shift).map(&:to_i)
  input.shift

  maps = input
    .slice_when { |b, _| b.empty? }
    .map { parse_map(_1) }
    .each_with_object({}) { _2[_1.source_name] = _1 }

  [seeds, maps]
end

def parse_map(lines)
  _, source, dest = lines.shift.match(/(\w+)-to-(\w+)/).to_a
  mapping = lines.reject(&:empty?).map { _1.split.map(&:to_i) }
  Map.new(source, dest, mapping)
end

MapRange = Struct.new(:min, :max, :delta, keyword_init: true)

class Map
  attr_reader :source_name, :dest_name, :mapping, :ranges

  def initialize(source_name, dest_name, mapping)
    @source_name = source_name.to_sym
    @dest_name = dest_name.to_sym
    @mapping = mapping
    @ranges = build_ranges
  end

  def build_ranges
    mapping.map { |dest, source, len|
      MapRange.new(
        min: source,
        max: source + len - 1,
        delta: dest - source
      )
    }.sort_by(&:min)
  end

  def to_s
    "#{source_name}-to-#{dest_name}: #{mapping}"
  end
end

def find(maps, source, source_ranges)
  # puts "#{source}: #{source_ranges}"
  return source_ranges.map(&:first) if source == :location

  map = maps.fetch(source)
  dest_ranges = []

  until source_ranges.empty?
    smin, smax = source_ranges.shift

    map.ranges.each do |r|
      break if smin > smax
      next if smax < r.min || smin > r.max

      min = [smin, r.min].max
      max = [smax, r.max].min
      dest_min = min + r.delta
      dest_max = max + r.delta

      if smin < r.min
        smax = r.min
        dest_ranges << [smin, r.min - 1]
      end

      smin = max + 1
      dest_ranges << [dest_min, dest_max]
    end

    dest_ranges << [smin, smax] if smin <= smax
  end

  find maps, map.dest_name, dest_ranges.sort_by(&:first)
end

input = read_input
seeds, maps = parse(input)

locations = find maps, :seed, seeds.map { [_1, _1] }
res = locations.min
puts "Day 5.1: #{res}"

seed_slices = seeds.each_slice(2).map { [_1, _1 + _2 - 1] }
locations = find maps, :seed, seed_slices
res2 = locations.min

puts "Day 5.2: #{res2}"
