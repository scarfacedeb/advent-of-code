# require "debug"

def read_input
  File.readlines(ENV["FULL"] == "1" ? "input.txt" : "example.txt").map(&:strip)
end

def pretty_print(seq)
  width = seq.first.map(&:to_s).join(" ").length + 2
  puts seq.map { _1.join(" ").center(width) }
  puts
end

def map_deltas(seq)
  seq.each_cons(2).map { _2 - _1 }
end

def calc_deltas(seq)
  deltas = map_deltas(seq)
  extras = [seq, deltas]

  until deltas.all?(&:zero?)
    deltas = map_deltas(deltas)
    extras << deltas
  end

  pretty_print extras
  extras.reverse
end

def calc_next_values(deltas)
  deltas.reduce(0) { |last_delta, seq| seq[-1] + last_delta }
end

def calc_prev_values(deltas)
  deltas.reduce(0) { |last_delta, seq| seq[0] - last_delta }
end

input = read_input
histories = input.map { _1.split.map(&:to_i) }
all_deltas = histories.map { |seq| calc_deltas(seq) }
next_values = all_deltas.map { |deltas| calc_next_values(deltas) }

res = next_values.sum
puts "Day 9.1: #{res}"

# == PART 2 ==

prev_values = all_deltas.map { |deltas| calc_prev_values(deltas) }
res2 = prev_values.sum
puts "Day 9.2: #{res2}"

# binding.irb
