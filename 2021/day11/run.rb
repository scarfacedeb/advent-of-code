require 'benchmark'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  input = File.read(ARGV.last || file).split("\n")
  input.map { _1.split('').map(&:to_i) }
end

p Benchmark.measure {

ADJACENT = [-1, 1, 0].repeated_permutation(2).reject { _1 == [0, 0] }.sort

octos = read_input

def draw(label = nil, octos)
  puts "=== #{label}" if label
  puts octos.map { _1.map { |e| e > 9 ? '*' : e }.join }.join("\n")
end

def step(octos, pos, from = nil)
  return if pos.any?(&:negative?)

  energy = octos.dig(*pos)
  return if energy.nil?

  i, j = pos

  octos[i][j] += 1
  # draw("#{pos.join('x')} from #{from&.join('x')}", octos)

  ADJACENT.each { step(octos, pos.zip(_1).map(&:sum)) } if energy == 9
end

def flash(octos, i, j)
  energy = octos.dig(i, j)
  return if energy.nil? || energy < 10

  octos[i][j] = 0
  ADJACENT.each { flash(octos, *_1) }
end

st = 1
total = 0
octos_count = octos.flatten.count

loop do
  octos.each_with_index { |row, i|
    row.each_with_index { |_col, j|
      step(octos, [i, j])
    }
  }

  # draw "STEP #{st + 1}", octos
  flashing = octos.flatten.count { |e| e > 9 }
  total += flashing
  break st if flashing == octos_count

  octos.each_with_index { |row, i|
    row.each_with_index { |_col, j|
      flash(octos, i, j)
    }
  }

  st += 1
end

puts "Answer 11.1: #{total}"
puts "Answer 11.2: #{st}"
}.total * 1000
