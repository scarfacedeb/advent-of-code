def read_input
  File.readlines(ENV["FULL"] == "1" ? "input.txt" : "example.txt").map(&:strip)
end

DELTAS = [0, 1, -1].repeated_permutation(2).to_a

def pos_around(y, x, len)
  0.upto(len - 1).map { |dx| [y, x + dx] }
    .flat_map { |pos| DELTAS.map { pos.zip(_1).map(&:sum) } }
    .reject { _1.any?(&:negative?) }
    .uniq
end

input = read_input

nums = []
syms = []

split = input.map { _1.split(/(\d+)|([^\.])/).reject(&:empty?) }
split.each.with_index do |row, y|
  x = 0
  row.each.with_index do |val|
    case val
    when /\d/
      nums << [
        val.to_i,
        pos_around(y, x, val.length)
      ]
    when /[^\.]/
      syms << [val, [y, x]]
    end

    x += val.length
  end
end

sym_coords = syms.map(&:last)
nums_adj = nums.select { |_, adj| (adj & sym_coords).any? }.map(&:first)
res = nums_adj.sum

puts "Day 3.1: #{res}"

gear_coords = syms.select { |sym, _| sym == '*' }.map(&:last)

res2 = gear_coords
  .map { |gear_pos| nums.select { |_, adj| adj.include?(gear_pos) }.map(&:first) }
  .select { _1.length == 2 }
  .map { _1.reduce(:*) }
  .sum

puts "Day 2.2: #{res2}"
