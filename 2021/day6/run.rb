def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file)
end


fish = read_input.split(',').map(&:to_i)

counter = Array.new(9, 0)
fish.tally.each { |num, count| counter[num] += count }

ans =
  1.upto(256).reduce(counter) { |acc, day|
    puts "Day: #{day} #{acc.sum}"
    # p acc.map.with_index.reduce([]) { |ff, (num, i)| ff += [i] * num }
    pregnant = acc.shift
    acc << pregnant
    acc[6] += pregnant
    acc
  }.sum

puts "Answer 6: #{ans}"
