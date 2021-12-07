require 'benchmark'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file)
end

# p Benchmark.measure {
crabs = read_input.split(',').map(&:to_i).sort!

range = Range.new(*crabs.minmax)

variants = range.map { |target| crabs.map { (_1 - target).abs } }

ans = variants.map(&:sum).min
ans2 = variants.map { |var| var.map { |d| (d*(d + 1)) / 2 }.sum }.min

puts "Answer 7.1: #{ans}"
puts "Answer 7.2: #{ans2}"
# }
