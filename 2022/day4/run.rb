def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n")
end

pairs = read_input.map { |l| l.split(",").map { |p| p.split("-").map(&:to_i) }.map { _1.._2 } }
subsets = pairs.select { _1.cover?(_2) || _2.cover?(_1) }

ans = subsets.count
puts "Answer 4.1: #{ans}"

overlaps = pairs.select { _1.to_a.intersect?(_2.to_a) }
ans2 = overlaps.count
puts "Answer 4.2: #{ans2}"
