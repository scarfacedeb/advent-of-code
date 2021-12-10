require 'benchmark'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file).split("\n")
end

p Benchmark.measure {
lines = read_input

opening = "([{<".chars
closing = ")]}>".chars
prices = closing.zip([3, 57, 1197, 25137]).to_h
values = opening.zip([1, 2, 3, 4]).to_h

regex = /((\(\))|(\[\])|({})|(<>))/

rest =
  lines.map { |line|
    loop { break unless line.gsub!(regex, "") }
    line
  }

invalid = rest.map { _1[/[)\]}>]/] }.compact

valid = rest.reject { _1[/[)\]}>]/] }

scores = valid.map { _1.chars.reverse }.map { |line|
  line.reduce(0) { |sum, ch| sum * 5 + values.fetch(ch) }
}

ans = invalid.map { prices[_1] }.sum
ans2 = scores.sort[scores.size / 2]

puts "Answer 10.1: #{ans}"
puts "Answer 10.2: #{ans2}"
}.total * 1000
