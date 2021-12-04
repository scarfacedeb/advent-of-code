require 'benchmark'

def read_input
  File.read($input || ARGV.first).split("\n")
end

def to_dec(binary)
  binary.join.to_i(2)
end

def day1
  depths = File.read('./puzzle1.txt').split("\n").map(&:to_i)

  answer1 = depths.each_cons(2).select { |b, a| a > b }.count
  puts "Answer 1: #{answer1}"

  answer2 = depths.each_cons(3).map(&:sum).each_cons(2).select { |b, a| a > b }.count
  puts "Answer 2: #{answer2}"
end

def move_to(pos, cmd, n)
  case cmd
  when 'forward'
    pos[:x] += n
    pos[:y] += pos[:aim] * n
  when 'down'
    pos[:aim] += n
  when 'up'
    pos[:aim] -= n
  end

  pos
end

def day2
  commands = File.read('./puzzle2.txt').split("\n").map { _1.split(' ') }
  initial = { x: 0, y: 0, aim: 0 }
  position = commands.reduce(initial) { |pos, (cmd, n)| move_to(pos, cmd, n.to_i) }
  puts position
  puts "Answer 3: #{position.values_at(:x, :y).reduce(:*)}"
end

def tally(nums)
  return [] if nums.empty?
  nums.first.count.times.map { |n| nums.map { _1[n] }.tally.to_a }
end

def find_common(nums, pos)
  counted = tally(nums)[pos].to_h
  return "1" if counted["0"] == counted["1"]
  counted["0"] <= counted["1"] ? "1" : "0"
end

def find_uncommon(nums, pos)
  counted = tally(nums)[pos].to_h
  return "0" if counted["0"] == counted["1"]
  (counted["0"] || 0) >= (counted["1"] || 0) ? "1" : "0"
end

def day3
  input = read_input.map { _1.chars }
  chars = input.first.count

  counted = tally(input)
  common = counted.map { |s| s.max_by(&:last).first }
  gamma = common.join.to_i(2)
  uncommon = counted.map { |s| s.min_by(&:last).first }
  epsilon = uncommon.join.to_i(2)

  puts "gamma=#{gamma}, epsilon=#{epsilon}"
  puts "Answer 3.1 #{gamma * epsilon}"

  oxygen = chars.times.reduce(input) { |acc, i|
    break acc if acc.size == 1
    target = find_common(acc, i)
    acc.select { |n| n[i] == target }
  }
  co2 = chars.times.reduce(input) { |acc, i|
    break acc if acc.size == 1
    target = find_uncommon(acc, i)
    acc.select { |n| n[i] == target }
  }
  oxygen = oxygen.join.to_i(2)
  co2 = co2.join.to_i(2)

  puts "oxygen=#{oxygen}, co2=#{co2}"
  puts "Answer 3.2 #{oxygen * co2}"
end

puts Benchmark.measure { day3 }
