PRIORITIES = (("a".."z").to_a + ("A".."Z").to_a).map.with_index(1).to_h

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").map(&:chars)
end

def calc_priorities(letters)
  letters.map { PRIORITIES[_1] }.sum
end

bags = read_input
compartments = bags.map { _1.each_slice(_1.length / 2).to_a }
common = compartments.flat_map { _1 & _2 }
ans = calc_priorities(common)

puts "Answer 2.1: #{ans}"


groups = bags.each_slice(3).to_a
common2 = groups.flat_map { _1.intersection(_2, _3) }
ans2 = calc_priorities(common2)

puts "Answer 2.2: #{ans2}"
