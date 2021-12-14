require "benchmark"

def read_input
  file = $all ? "input.txt" : "example.txt"
  input = File.read(ARGV.last || file).split("\n")
  template, rules = input.slice_after("").to_a
  rules = rules.map { _1.split(' -> ') }
  [template.first.chars, rules.to_h]
end

def tally(temp)
  temp.chars.each_cons(2).tally.transform_keys(&:join).sort_by(&:first).to_h
end

def count(pairs)
  pairs.reduce({}) { |acc, (pair, num)|
    f, s = pair.chars
    acc[f] ||= 0
    acc[f] += num
    acc
  }
end


p Benchmark.measure {
template, rules = read_input

chars = rules.values.uniq
pairs = template.each_cons(2).tally.transform_keys(&:join)

last_char = template.last

# puts "STEP: 0"
# p count(pairs)

($tries || 40).times do |st|
  # template =
  #   template.each_cons(2).flat_map { |f, s|
  #     np = [f, rules["#{f}#{s}"]]
  #     puts "T: #{np.join}"
  #     np
  #   } + [template.last]

  pairs = pairs.reduce({}) do |acc, (pair, num)|
    next acc if num.zero?

    f, s = pair.chars
    inserted = rules[pair]
    ins_f = "#{f}#{inserted}"
    ins_s = "#{inserted}#{s}"

#     puts "#{ins_f} & #{ins_s}"

    acc[ins_f] ||= 0
    acc[ins_f] += num
    acc[ins_s] ||= 0
    acc[ins_s] += num
    acc
  end

  # puts "STEP: #{st + 1} #{count(pairs)}"
end


counts = count(pairs)

counts[last_char] += 1

min, max = p(counts.minmax_by(&:last)).map(&:last)
ans = max - min

# min, max = template.tally.minmax_by(&:last).map(&:last)
# ans2 = max - min

# binding.pry if ans != ans2

puts "Answer 14: #{ans}"

}.total * 1000
