require "benchmark"
require "set"
require "logger"
require "debug"
require "colorize"

def read_input
  file = $all ? "input.txt" : "example.txt"
  input = File.read(ARGV.last || file).split("\n")
  input.map { eval(_1) }
end

def int?(*v) = v.all? { _1.is_a?(Num) || _1.is_a?(Integer) }
def pair?(v) = v.is_a?(Array) || v.is_a?(Pair)

LOGGER = Logger.new(STDOUT, formatter: ->(_, _, _, msg) { "  #{msg}\n" })
def log(msg) = LOGGER.debug(msg)

class Num
  include Comparable
  def self.[](*args) = new(*args)

  attr_accessor :val, :up, :prev, :nxt, :level

  def initialize(val, level = nil, up = nil, prev = nil, nxt = nil)
    @val = val
    @up = up
    @prev = prev
    @nxt = nxt
    @level = level
  end

  def +(other) = Num[@val + other.val, level, up, prev, nxt]
  def -(other) = Num[@val - other.val, level, up, prev, nxt]
  def /(other) = Num[val / other, level, up, prev, nxt]
  def ceil = Num[@val.ceil, level, up, prev, nxt]
  def floor = Num[@val.floor, level, up, prev, nxt]

  def <=>(other) = val <=> other

  def to_i = val
  def to_a = val
  def to_s = inspect.yellow
  def inspect = "+#{val}"

  def root
    root = up
    root = root.up while root.up
    root
  end

  def add_to_last_right(num)
    # log "  ADD_TO_LAST_RIGHT #{self} + #{num.val}"
    @val += num.val
  end

  def add_to_first_left(num)
    # log "  ADD_TO_FIRST_LEFT #{self} + #{num.val}"
    @val += num.val
  end
end

class Pair
  attr_accessor :left, :right, :prev, :nxt, :level, :up

  def self.[](*args) = new(*args)

  def initialize(left, right, level = 0, prev = nil, nxt = nil, up = nil)
    @left = left
    @right = right
    @prev = prev
    @nxt = nxt
    @level = level
    @up = up
  end

  def to_s = inspect
  def inspect = [left, right].inspect

  def to_a
    [left, right].map(&:to_a)
  end

  def root
    root = up
    root = root.up while root.up
    root
  end

  def add_to_last_right(num)
    last_right = right
    last_right = last_right.right until int?(last_right)
    last_right.add_to_last_right(num)
  end

  def add_to_first_left(num)
    first_left = left
    first_left = first_left.left until int?(first_left)
    first_left.add_to_first_left(num)
  end
end

def build(val, level = 1)
  left, right = val.is_a?(Pair) ? [val.left, val.right] : val
  left = Num[left, level + 1] if left.is_a?(Integer)
  right = Num[right, level + 1] if right.is_a?(Integer)

  # log "L#{level} >> #{left}  |  #{right}"

  left_num = int?(left) ? left : build(left, level + 1)
  right_num = int?(right) ? right : build(right, level + 1)

  # log "L#{level} << #{left_num}  |  #{right_num}"

  Pair[left_num, right_num, level]
end

def assign_next(num, prev = nil, nxt = nil)
  num.left.nxt = num.right
  num.left.prev = prev
  num.left.up = num

  num.right.nxt = nxt
  num.right.prev = num.left
  num.right.up = num

  assign_next(num.left, prev, num.right) unless int?(num.left)
  assign_next(num.right,num.left, nxt) unless int?(num.right)

  num
end

def build_rec(input) = assign_next(build(input))

def split(num, dir = nil)
  res = (num.val / 2.0)
  left = Num[res.floor, num.level + 1]
  right = Num[res.ceil, num.level + 1]
  pair = Pair[left, right, num.level, num.prev, num.nxt, num.up]

  # binding.b if @steps >= 12
  # num.nxt.prev = pair if num.nxt
  # if pair.nxt
  #   first_left = pair.nxt
  #   loop do
  #     first_left.prev = pair
  #     break if int?(first_left)
  #     first_left = first_left.left
  #   end
  # end
  # pair.nxt.prev = pair
    # num.prev.nxt = pair if num.prev

  left.nxt = right
  left.prev = num.prev
  right.prev = left
  right.nxt = num.nxt
  left.up = pair
  right.up = pair

  @restart = true

  # binding.b

  # num.prev.nxt = exploded if num.prev

  # log "  SPLIT #{dir}#{pair.level} #{pair.left}  |  #{pair.right} (from: #{num})"
  # log "    ## #{pair.root&.to_a}"
  # binding.b
  pair
end

def explode(num, dir = nil)
  # binding.b if [80, 78, 73].include?(@steps)
  num.prev&.add_to_last_right(num.left)
  num.nxt&.add_to_first_left(num.right)

  exploded = Num[0, num.level, num.up, num.prev, num.nxt]
  # num.nxt.prev = exploded if num.nxt && num
  # num.prev.nxt = exploded if num.prev

#   log "  BOOM #{dir}#{exploded.level} << #{exploded} (from: #{num.left}  |  #{num.right})"
#   log "    ## #{exploded.root&.to_a} ##"

  @restart = true

  # binding.b

  exploded
end

def reduce_explode(num, dir = 'L')
  # log " #{dir}#{num.level} >> #{num} << NUM" if int?(num)
  return num if int?(num)

  # log "#{dir}#{num.level} >> #{num.left}  |  #{num.right}" if num.level == 1
  # binding.b if !int?(num) && num.left == 15

  # binding.b if num.level == 5 && num.left.val == 7 && num.right.val == 6

  if num.level > EXPLODE_LEVEL
    return explode(num, dir)
  end

  num.left = reduce_explode(num.left, 'L')
  num.left.nxt.prev = num.left if num.left.nxt

#   num.left.nxt = num.right
#   num.left.prev = prev
#   num.right.nxt = nxt
#   num.right.prev = num.left

  # binding.b if @restart && @steps >= 77
  # return reduce_explode(num.root) if restart
  throw(:explode, num) if @restart

  num.right = reduce_explode(num.right, 'R')
  num.right.prev.nxt = num.right if num.right.prev

  # return reduce_explode(num.root) if restart

  # binding.b if @restart && @steps >= 77
  throw(:explode, num) if @restart

  # log "#{dir}#{num.level} << #{num.left}  |  #{num.right}"

  # Pair[left_num, right_num, num.level]
  num
end

def reduce_split(num, dir = nil)
  # log " #{dir}#{num.level} >> #{num} << NUM" if int?(num)
  return num if int?(num)

  # log "#{dir}#{num.level} >> #{num.left}  |  #{num.right}"
  # binding.b if !int?(num) && num.left == 15

  # binding.b if num.level == 5 && num.left.val == 7 && num.right.val == 6

  num.left =
    if int?(num.left) && num.left >= 10
      split(num.left, dir)
    else
      reduce_split(num.left, 'L')
    end

  # return reduce_explode(num.root) if restart

  # binding.b if @restart && @steps >= 12
  # binding.b if @restart && @steps >= 76
  throw(:split, num) if @restart

  num.right =
    if int?(num.right) && num.right >= 10
      split(num.right, dir)
    else
      reduce_split(num.right, 'R')
    end

  # binding.b if @restart && @steps >= 12
  # return reduce_explode(num.root) if restart
  throw(:split, num) if @restart

  # log "#{dir}#{num.level} << #{num.left}  |  #{num.right}"

  # Pair[left_num, right_num, num.level]
  num
end

def reduce(num, dir = nil)
  log " #{dir}#{num.level} >> #{num} << NUM" if int?(num)
  return num if int?(num)

  log "#{dir}#{num.level} >> #{num.left}  |  #{num.right}"
  # binding.b if !int?(num) && num.left == 15

  # binding.b if num.level == 5 && num.left.val == 7 && num.right.val == 6

  if num.level > EXPLODE_LEVEL
    return explode(num, dir)
  end

  num.left =
    if int?(num.left)
      reduce(num.left >= 10 ? split(num.left, dir) : num.left, 'L')
    else
      reduce(num.left, 'L')
    end

  throw(:restart, num) if @restart

  num.right =
    if int?(num.right)
      reduce(num.right >= 10 ? split(num.right, dir) : num.right, 'R')
    else
      reduce(num.right, 'R')
    end

  throw(:restart, num) if @restart

  log "#{dir}#{num.level} << #{num.left}  |  #{num.right}"

  # Pair[left_num, right_num, num.level]
  num
end

@steps = 0

def highlight(num, hl)
  num.to_a.to_s
    # .gsub(/(\[.*?\[.*?\[.*?\[.*?)(\[\d+, \d+\])(.*?\].*?\].*?\].*?\])/, '\1' + '\2'.blue + '\3')
    # .gsub(/\d{2}/) { _1.yellow }
    .gsub(Regexp.new(Regexp.escape(hl.to_a.to_s))) { _1.red }
end

def sum(input, dir = 'L', event = :INIT, hl = nil)
  num = build_rec(input)

  @steps += 1
  log "#{@steps.to_s.rjust(3)}: #{event} #{highlight(num, hl)}"

  @restart = false

  hl = catch(:split) do
    hl = catch(:explode) do
      return reduce_split(reduce_explode(num, dir))
    end

    return sum(num.to_a, dir, :EXPL, hl)
  end

  return sum(num.to_a, dir, :SPLT, hl)
end

def calc_magnitude(num)
  left = int?(num.left) ? num.left.val : calc_magnitude(num.left)
  right = int?(num.right) ? num.right.val : calc_magnitude(num.right)
  left * 3 + right * 2
end

EXPLODE_LEVEL = 4

inputs = read_input

res = sum(inputs.first) if inputs.size == 1
res ||= inputs.reduce { sum([_1.to_a, _2]) }

ans = calc_magnitude(res)

ans2 = inputs.permutation(2).map { calc_magnitude(sum([_1, _2])) }.max

puts "Answer 18.1: #{ans}"
puts "Answer 18.2: #{ans2}"
