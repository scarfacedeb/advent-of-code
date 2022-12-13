require 'debug' if ENV['DEBUG']

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").each_slice(3).map { _1.reject(&:empty?) }
end

def compare(left, right)
  case [left, right]
  in [_, nil]
    false
  in [nil, _]
    true
  in [Integer, Integer]
    return :next if left == right
    left < right
  in [Integer, Array]
    compare([left], right)
  in [Array, Integer]
    compare(left, [right])
  in [Array, Array]
    [left.size, right.size].max.times.each {
      res = compare(left[_1], right[_1])
      return res unless res == :next
    }
    :next
  end
end

pairs = read_input.map { |l| l.map { eval(_1) } }

checks = pairs.map { compare(_1, _2) }
ans = checks.map.with_index(1).select(&:first).sum(&:last)

puts "Answer 13.1: #{ans}"

DEC_1 = [[2]]
DEC_2 = [[6]]

def order(left, right)
  case [left, right]
  in [_, nil]
    1
  in [nil, _]
    -1
  in [Integer, Integer]
    return :next if left == right
    left <=> right
  in [Integer, Array]
    order([left], right)
  in [Array, Integer]
    order(left, [right])
  in [Array, Array]
    [left.size, right.size].max.times.each {
      res = order(left[_1], right[_1])
      return res unless res == :next
    }
    :next
  end
end


packets = (pairs.flatten(1) + [DEC_1, DEC_2]).sort { order(_1, _2) }

idx_1 = packets.index(DEC_1) + 1
idx_2 = packets.index(DEC_2) + 1
ans_2 = idx_1 * idx_2

puts "Answer 13.2: #{ans_2}"
