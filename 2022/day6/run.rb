def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).strip.chars
end

def find_uniq(signal, size)
  signal.each_cons(size).to_a.index { _1.uniq.size == size } + size
end

signal = read_input
ans = find_uniq(signal, 4)
puts "Answer 6.1: #{ans}"

ans2 = find_uniq(signal, 14)
puts "Answer 6.2: #{ans2}"
