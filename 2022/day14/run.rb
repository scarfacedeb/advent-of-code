require "debug"

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file)
    .split("\n")
    .map { |l|
      l.split(" -> ").map {
        _1.split(",").map(&:to_i)
      }
    }
end

def draw(cave)
  puts cave.map { _1.drop(450).join }.join("\n")
end

def line(from, to)
  delta = to.zip(from).map { _1 - _2 }
  case delta
  in [dx, 0]
    (dx > 0 ? 0..dx : dx..0).map { [_1, 0] }
  in [0, dy]
    (dy > 0 ? 0..dy : dy..0).map { [0, _1] }
  end
end

SAND_GEN = [500, 0]

def scan_cave(rocks)
  width = rocks.flat_map { |l| l.map(&:first) }.max + 1
  height = rocks.flat_map { |l| l.map(&:last) }.max + 3

  # h = Hash.new { |h, k| h[k] = [] }

  cave = height.times.map { |y|
    width.times.map { |x|
      if [x, y] == SAND_GEN
        '+'
      elsif y == height-1
        '#'
      else
        '.'
      end
    }
  }

  rocks.each do |wall|
    wall.each_cons(2) do |from, to|
      x, y = from
      line(from, to).each do |dx, dy|
        cave[y + dy][x + dx] = '#'
      end
    end
  end

  cave
end

def flow(cave, x, y, last_pos = SAND_GEN)
  val = cave.dig(y, x)
  # if !val && y == (cave.size - 1)
  #   cave.each { |row| row << '.' }
  #   val = '#'
  #   cave[y][x] = val
  # end

  case val
  when nil
    :void
  when '+'
    pos = flow(cave, x, y + 1, [x, y])
    return :stop if pos == SAND_GEN
    pos
  when '.'
    flow(cave, x, y + 1, [x, y])
  when '#', 'o'
    lval = cave.dig(y, x - 1)
    if !lval
      cave[..-2].each { |row| row.shift '.' }
      cave[-1].shift '#'
      lval = cave.dig(y, x - 1)
    end
    return flow(cave, x - 1, y, last_pos) if lval == '.'

    rval = cave.dig(y, x + 1)
    if !rval
      cave[..-2].each { |row| row << '.' }
      cave[-1] << '#'
      rval = cave.dig(y, x + 1)
    end
    return flow(cave, x + 1, y, last_pos) if rval == '.'

    last_pos
  end
end

def gen_sand(cave)
  dest = flow(cave, *SAND_GEN)
  return :void if dest == :void
  return p(:stop) if dest == :stop

  x, y = dest
  cave[y][x] = 'o'
end

cave = scan_cave(read_input)

loop { break if gen_sand(cave) == :stop }
draw(cave)

ans = cave.flatten.count { _1 == 'o' } + 1
puts "Answer 14.2: #{ans}"

# ans2 = cave.flatten.count { _1 == 'o' }
# puts "Answer 14.2: #{ans2}"
