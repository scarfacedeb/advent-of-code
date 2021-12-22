require "benchmark"
require "set"
require "logger"
require "debug"

def read_input
  file = $all ? "input.txt" : "example.txt"
  input = File.read(ARGV.last || file).split("\n")
  input.map { eval(_1) }
end

def add(num, num2, _level = 0)
  [num, num2]
end

def int?(*v) = v.all? { _1.is_a?(Integer) }
def pair?(v) = v.is_a?(Array)

def split(num)
  res = (num / 2.0)
  [res.floor, res.ceil]
end

# def split(int, prev, n, level)
#   res = (int / 2.0)
#   Num[res.floor, res.ceil, prev, n, level]
# end

def explode(num)
  num
end

LOGGER = Logger.new(STDOUT, formatter: -> (_, _, _, msg) { "  #{msg}\n" })

def log(msg) = LOGGER.debug(msg)

def reduce(left, right, level = 1, stack = [])
  log "L#{level} >> #{left}  |  #{right}"

  if level > EXPLODE_LEVEL
    if pair?(left)
      left_exp, right_exp = left

      if int?(right)
        right_num = right + right_exp
      else
        first_pair = right
        first_pair = first_pair[0] until int?(*first_pair)
        first_pair[0] += right_exp
        right_num = right
        # right_num = first.tap { _1[0] += right_exp }
      end

      @add_prev_right = left_exp

      log "BLAST_L L#{level}: [0,#{right_num}] from [#{left}, #{right}] carry PREV RIGHT #{@add_prev_right}"
      # binding.b

      # binding.b if right_num == [[7,8],5]

      exploded = reduce(0, right_num, level)
      # exploded = [0, reduce(*right_num, level)]

        # binding.b
      ## 2 PAIRS
      if pair?(right) && false
        left, right = exploded
        left_exp, right_exp = right
        left_num = int?(left) ? left + left_exp : left.dup.tap { _1[0] += left_exp }

        # @add_prev_right = nil
        @add_next_left = right_exp

        log "BLAST_2R L#{level}: [#{left_num},0] from [#{left}, #{right}] carry NEXT LEFT #{@add_next_left}}"

        # return [reduce(*left_num, level), 0]
        return [left_num, 0]
      end

      return exploded
    end

    if pair?(right)
      left_exp, right_exp = right

      binding.b if left_exp == [7,8]

      left_num = int?(left) ? left + left_exp : left.tap { _1[0] += left_exp }

      @add_next_left = right_exp

      log "BLAST_R L#{level}: [#{left_num},0] from [#{left}, #{right}] carry NEXT_LEFT #{@add_next_left}"
      # binding.b

      # return [reduce(*left_num, level), 0]
      return [left_num, 0]
    end
  end

  if @add_next_left && int?(left)
    log "BLAST_R_L L#{level}: #{left} + #{@add_next_left}  |  #{right}"
    left += @add_next_left
    @add_next_left = nil
  end

  if @add_prev_right && int?(right) && left != 15
    log "BLAST_L_R L#{level}: #{left}  |  #{right} + #{@add_prev_right}"
    # binding.b
    right += @add_prev_right
    @add_prev_right = nil
  end

  if int?(left)
    left_num = left >= 10 ? split(left) : left
  else
    left_num = reduce(*left, level + 1, stack + [0])
  end

  if int?(right)
    right_num = right >= 10 ? split(right) : right
    @last_right = stack if int?(right_num)
  else
    right_num = reduce(*right, level + 1, stack + [1])
  end

  log "L#{level} << #{left_num}  |  #{right_num}"

  if @add_next_left && int?(right_num)
    log "BLAST_R_R L#{level}: #{left_num} + #{@add_next_left}  |  #{right_num}"
    right_num += @add_next_left
    @add_next_left = nil
  end

  if @add_prev_right && int?(left_num)
    # binding.b
    log "BLAST_L_L L#{level}: #{left_num} + #{@add_prev_right}  |  #{right_num}"
    left_num += @add_prev_right
    @add_prev_right = nil
  end

  if @add_prev_right && @last_right && @last_right.take(1) == stack
    # binding.b
    log "BLAST_PR_STACK L#{level}: #{left_num} |  #{right_num} + #{@add_prev_right}"
    nested_in = @last_right - stack
    last_i = nested_in.pop
    last_pair = nested_in.empty? ? left_num : left_num.dig(*nested_in)
    last_pair[last_i] = last_pair[last_i] + @add_prev_right
    # binding.b

    @add_prev_right = nil
    @last_right = nil
  end


  # binding.b if left_num == [[4, 0], [5, 0]]

  return [left_num, right_num]
end

def reduce_loop(last_res)
  @add_prev_right, @add_next_left, @last_right = nil, nil, nil
  reduce(*last_res)
  # loop do
  #   @add_prev_right, @add_next_left = nil, nil
  #   res = reduce(*last_res)
  #   break if res == last_res
  #   log "REDUCED: #{res}"
  #   last_res = res
  #   break
  # end

  # last_res
end

LOGGER.level = $level || 0
EXPLODE_LEVEL = 3

inputs = read_input.first
p inputs

summed = inputs.reduce { p reduce_loop([_1, _2]) }

puts "#"*30
p summed
# inputs = [
#   [[[[[9,8],1],2],3],4],
#   [7,[6,[5,[4,[3,2]]]]],
#   [[6,[5,[4,[3,2]]]],1],
#   [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]],
#   [[[[[4,3],4],4],[7,[[8,4],9]]], [1,1]]
# ]

# expected = [
#   [[[[0,9],2],3],4],
#   [7,[6,[5,[7,0]]]],
#   [[6,[5,[7,0]]],3],
#   [[3,[2,[8,0]]],[9,[5,[7,0]]]],
#   [[[[0,7],4],[[7,8],[6,0]]],[8,1]]
# ]

# inputs.zip(expected).each { |input, exp|
#   puts "▼▼▼▼"
#   p input
#   res = reduce_loop(input)

#   if res == exp
#     puts "<OK>"
#   else
#     puts "###### ERROR: ########"
#     p res
#     p exp
#     puts "#"*22
#     break
#   end
# }
