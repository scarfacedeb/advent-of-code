require "debug"

def read_input
  File.readlines(ENV["FULL"] == "1" ? "input.txt" : "example.txt").map(&:strip)
end

def parse(input)
  times, distances = input
  times = times.split.tap(&:shift).map(&:to_i)
  distances = distances.split.tap(&:shift).map(&:to_i)

  times.zip(distances)
end

def ceil(val) = (val + 0.001).ceil
def floor(val) = (val - 0.001).floor

# x2 - tx + d
def calc_x(time, dist)
  d = Math.sqrt(time**2 - 4 * dist)
  x_min = (time - d) / 2
  x_max = (time + d) / 2

  # puts "#{x_min} .. #{x_max}"
  [ceil(x_min), floor(x_max)]
end

def calc(time, dist)
  min, max = calc_x(time, dist)
  max - min + 1
end

input = read_input
races = parse(input)

nums = races.map { calc(*_1) }
res = nums.reduce(:*)

puts "Day 6.1: #{res}"

race = input.map { _1.split(":").last.gsub(" ", "").to_i }
res2 = calc(*race)

puts "Day 6.2: #{res2}"

# binding.irb
