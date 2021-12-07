require 'benchmark'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file)
end

puts Benchmark.measure {
  crabs = read_input.split(',').map(&:to_i).sort

  range = crabs.min.upto(crabs.max)

  ans =
    range.map { |target|
      crabs.map { (_1 - target).abs }.sum
    }.min

  ans2 =
    range.map { |target|
      crabs.map { (_1 - target).abs }.map { |d| (d*d + d) / 2 }.sum
    }.min


  puts "Answer 7.1: #{ans}"
  puts "Answer 7.2: #{ans2}"
}
