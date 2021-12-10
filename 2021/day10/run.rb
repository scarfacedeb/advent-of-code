require 'benchmark'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file).split("\n")
end

# p Benchmark.measure {
lines = read_input

invalid = []
opening = "([{<".chars
closing = ")]}>".chars
pairs = closing.zip(opening).to_h
prices = closing.zip([3, 57, 1197, 25137]).to_h
values = opening.zip([1, 2, 3, 4]).to_h

scores =
  lines.map { |line|
    stack = []

    line.each_char do |ch|
      case ch
      when *opening
        stack << ch
      when *closing
        next if stack.pop == pairs[ch]
        invalid << ch
        stack << :invalid
        break
      end
    end

    next if stack.last == :invalid

    stack.reverse.reduce(0) { |sum, ch|
      sum * 5 + values.fetch(ch)
    }
  }.compact

ans = invalid.map { prices[_1] }.sum
ans2 = scores.sort[scores.size / 2]

puts "Answer 10.1: #{ans}"
puts "Answer 10.2: #{ans2}"
# }.total * 1000
