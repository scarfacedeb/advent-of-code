require "benchmark"
require "bigdecimal"

def read_input
  file = $all ? "input.txt" : "example.txt"
  input = File.read(ARGV.last || file).strip
  input.match(/x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)/) { _1.captures.map(&:to_i).each_slice(2) }.to_a
end

def draw(target, positions)
  x_range, y_range = target
  max_y = [positions.map(&:last).max, 0].max
  min_y = [positions.map(&:last).min, y_range.min].min
  max_x = [x_range.max, positions.map(&:first).max].max + 1

  map =
    max_y.downto(min_y).map { |y|
      max_x.times.map { |x|
        if positions.include?([x, y])
          "#"
        elsif x_range.include?(x) && y_range.include?(y)
          "T"
        elsif y == 0 && x == 0
          "S"
        else
          "."
        end
      }.join
    }

  puts map
end

# x = 7
# y = 2
# parabola = -4 * a * y

def launch(target, vel, draw: false)
  x_range, y_range = target
  vel_x, vel_y = vel

  max_x, min_y = x_range.max, y_range.min
  x, y = 0, 0
  positions = Set.new
  last_pos = nil

  # until y <= max_y && (x <= max_x || !vel_x.zero?)
  # while y > max_y
  # while y > min_y
  # until y < min_y || (x > max_x || vel_x.zero?)

  loop do
    x += vel_x
    y += vel_y

    vel_x -= 1 if vel_x > 0
    vel_x += 1 if vel_x < 0
    vel_y -= 1

    positions << [x, y] if draw

    break if y < min_y || x > max_x
    last_pos = [x, y]
  end

  draw(target, positions) if draw

  [last_pos, positions]
end

def triangle(n) = (n + 1) * n / 2
def rev_triangle(t) = (BigDecimal(2 * t + 1 / 4).sqrt(2) - 0.5).ceil

def hit?(target, pos)
  x_range, y_range = target
  x, y = pos

  x_range.include?(x) && y_range.include?(y)
end

target = read_input.map { Range.new(*_1) }
x_range, y_range = target

width = x_range.reduce(&:-).abs
height = y_range.reduce(&:-).abs

min_vel_x = rev_triangle(x_range.min)
max_vel_x = x_range.max

vel_y = -100
last_pos = nil
positions = nil
first_hit = false
last_hit = nil
hits = Set.new

min_vel_x.upto(max_vel_x).each do |vel_x|
  vel_y = -800
  (vel_y * -2).times do
    last_pos, positions = launch(target, [vel_x, vel_y])
    hit = hit?(target, last_pos)
    # first_hit = true if !first_hit && hit
    # break if first_hit && !hit
    last_hit = [last_pos, positions] if hit
    hits << [vel_x, vel_y] if hit
    vel_y += 1
  end
end

last_pos, positions = last_hit

p hits

# ans = positions.map(&:last).max
# puts "Answer 17.1: #{ans}"

ans2 = hits.count

puts "Answer 17.2: #{ans2}"
