require 'benchmark'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file).split("\n")
end

class Vent
  attr_reader :start, :end

  def initialize(coords)
    @start, @end = coords.map { |x, y| { x: x, y: y } }
  end

  def straight?
    @start[:x] == @end[:x] || @start[:y] == @end[:y]
  end

  def points
    move_x = (@start[:x] - @end[:x]).abs
    move_y = (@start[:y] - @end[:y]).abs
    oper_x = @end[:x] > @start[:x] ? '+' : '-'
    oper_y = @end[:y] > @start[:y] ? '+' : '-'

    moves_x = 0.upto(move_x).map { |i| @start[:x].send(oper_x, i) }
    moves_y = 0.upto(move_y).map { |j| @start[:y].send(oper_y, j) }

    last_x = moves_x.last
    last_y = moves_y.last
    moves = [moves_x.size, moves_y.size].max

    if moves_x.size > moves_y.size
      moves_x.zip(moves_y).map { |x, y|
        { x: x || last_x, y: y || last_y }
      }
    else
      moves_y.zip(moves_x).map { |y, x|
        { x: x || last_x, y: y || last_y }
      }
    end

    # @start[:x].upto(@end[:x]).map do |i|
    #   @start[:y].upto(@end[:y]).map do |j|
    #     { x: i, y: j }
    #   end
    # end.flatten
  end
end

def create_board(vents)
  ends = vents.map(&:end)
  max_x = ends.map { _1[:x] }.max + 1
  max_y = ends.map { _1[:y] }.max + 1
  empty = Array.new(max_y) { Array.new(max_x, 0) }

  vents.reduce(empty) { |acc, v|
    v.points.reduce(acc) { |acc2, ps|
      acc2[ps[:y]][ps[:x]] += 1
      acc2
    }
  }
end

def draw(board)
  puts board.map { _1.map { |p| p.zero? ? '.' : p }.join('') }
end

input = read_input
vents = input.map { _1.split(' -> ').map { |l| l.split(',').map(&:to_i) }.sort }.sort.map { Vent.new(_1) }

board_s = create_board(vents.select(&:straight?))
ans1 = board_s.flatten.count { _1 >= 2 }
puts "Answer 5.1: #{ans1}"

board = create_board(vents)
draw(board)

ans2 = board.flatten.count { _1 >= 2 }
puts "Answer 5.2: #{ans2}"
