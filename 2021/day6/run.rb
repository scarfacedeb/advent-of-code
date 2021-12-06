def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file)
end


fish = read_input.split(',').map(&:to_i)
days = 1

# counter = 0.upto(8).map { |d| [d, 0] }.to_h
# fish.each { |d| counter[d] += 1 }
# counter = fish.tally
counter = Array.new(9, 0)
fish.tally.each { |num, count| counter[num] += count }
counter

ans =
  days.upto(256).reduce(counter) { |acc, day|
    puts "Day: #{day} #{acc.sum}"
    # p acc.map.with_index.reduce([]) { |ff, (num, i)| ff += [i] * num }
    pregnant = acc.shift
    acc << pregnant
    acc[6] += pregnant
    acc
  }.sum

puts "Answer 5: #{ans}"
