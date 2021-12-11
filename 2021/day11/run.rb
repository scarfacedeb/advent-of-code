require 'benchmark'
require 'colorize'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  input = File.read(ARGV[-3] || file).split("\n")
  input.map { _1.split('').map(&:to_i) }
end

# p Benchmark.measure {

ADJACENT = [-1, 1, 0].repeated_permutation(2).reject { _1 == [0, 0] }.sort

octos = read_input

def animate(st, flashing, octos)
  delay = ARGV[-2].to_f

  before, after = false, true
  3.times { |f|
    after = draw("STEP #{st}", octos, f)
    if before != after
      system 'clear'
      puts after
      before = after
    end
    sleep delay
  }
end

def draw(label, octos, f)
  "  #{label}\n" + octos.map { _1.map { |e| color(e, f) }.join }.join("\n")
end

def color(e, f)
  case e
  when 1..8 then e.to_s.colorize(:white)
  when 9 then e.to_s.colorize(f < 1 ? :white : :yellow)
  when 0 then '*'.colorize(f < 1 ? :yellow : :red)
  end
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

st = 1
total = 0
rows, cols = octos.count, octos.first.count
octos_count = rows * cols

loop do
  rows.times do |i|
    cols.times do |j|
      step(octos, [i, j])
    end
  end

  flashing = 0

  rows.times do |i|
    cols.times do |j|
      next if octos[i][j] < 10

      octos[i][j] = 0
      flashing += 1
    end
  end

  animate st, flashing, octos if st > ARGV[-1].to_i

  total += flashing if st <= 100
  break st if flashing == octos_count

  st += 1
end

puts "Answer 11.1: #{total}"
puts "Answer 11.2: #{st}"
# }.total * 1000
