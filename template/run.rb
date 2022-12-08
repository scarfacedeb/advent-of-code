def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n")
end

input = read_input

ans = nil
puts "Answer N.1: #{ans}"

ans2 = nil
puts "Answer N.2: #{ans2}"
