

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file).split("\n")
end

input = read_input
calories = input.slice_before('').map { _1.map(&:to_i).sum }.sort

max_calories = calories.last
puts "Answer 1.1: #{max_calories}"

top3 = calories.last(3).sum
puts "Answer 1.2: #{top3}"
