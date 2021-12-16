require "benchmark"

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).strip
end

def parse_packets(binary, num = nil)
  packets = []
  until binary.empty? || num&.zero?
    packets << parse_packet(binary)
    num -= 1 if num
  end
  packets
end

def parse_packet(binary)
  packet = []

  ver = binary.shift(3).join.to_i(2)
  type = binary.shift(3).join.to_i(2)

  packet << [:ver, ver] << [:type, type]

  if type == 4
    parse_literal(binary, packet)
  else
    parse_operand(binary, packet)
  end
end

def parse_literal(binary, packet)
  value = []

  begin
    first_chr = binary.shift
    value += binary.shift(4)
  end until first_chr == "0"

  packet << [:literal, value.join.to_i(2)]
end

def parse_operand(binary, packet)
  length_type = binary.shift
  packet << [:length_type, length_type.to_i(2)]

  if length_type == "0"
    length = binary.shift(15).join.to_i(2)
    packet << [:bit_length, length]
    packet << parse_packets(binary.shift(length))
  else
    length = binary.shift(11).join.to_i(2)
    packet << [:num_length, length]
    packet << parse_packets(binary, length)
  end
end

def calc_value(packet)
  id, type = packet.shift until id == :type

  if type == 4
    id, literal = packet.shift until id == :literal
    return literal
  end

  values = packet.pop.map { calc_value(_1) }

  case type
  when 0 then values.sum
  when 1 then values.reduce(&:*)
  when 2 then values.min
  when 3 then values.max
  when 5 then values.reduce(&:-) > 0 ? 1 : 0
  when 6 then values.reduce(&:-) < 0 ? 1 : 0
  when 7 then values.reduce(&:-) == 0 ? 1 : 0
  end
end

p Benchmark.measure {
input = read_input
binary = input.chars.flat_map { _1.to_i(16).to_s(2).rjust(4, "0").chars }

packets = parse_packet(binary)

ans = packets.flatten.slice_when { |b, a| a == :ver }.map { _1[1] }.sum
ans2 = calc_value(packets)

puts "Day 16.1: #{ans}"
puts "Day 16.2: #{ans2}"

}.total * 1000
