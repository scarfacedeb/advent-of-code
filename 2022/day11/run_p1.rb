require 'debug'

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").slice_after("").map { _1.map(&:strip).reject(&:empty?) }
end

class Monkey
  attr_reader :id, :items, :operation, :test_div, :monkey_true, :monkey_false, :inspected

  def initialize(lines)
    parse(lines)
    @inspected = 0
  end

  def parse(lines)
    @id = lines.shift.match(/Monkey (\d+):/)[1].to_i
    @items = lines.shift.match(/items: (.*)/)[1].split(", ").map(&:to_i)
    @operation = parse_operation(lines.shift)
    # @operation = lines.shift.match(/Operation: new = (.*)/)[1]
    @test_div = lines.shift.match(/Test: divisible by (\d+)/)[1].to_i
    @monkey_true = lines.shift.match(/If true: throw to monkey (\d+)/)[1].to_i
    @monkey_false = lines.shift.match(/If false: throw to monkey (\d+)/)[1].to_i
  end

  def parse_operation(line)
    _, oper, num = line.match(/Operation: new = old ([\+\*]) (\w+)/).to_a
    num = num == 'old' ? :old : num.to_i
    case oper
    when "*"
      if num == :old
        -> (old) { old * old }
      else
        -> (old) { old * num }
      end
    when "+"
      if num == :old
        -> (old) { old + old }
      else
        -> (old) { old + num }
      end
    end
  end

  def 🕵️
    while items.any?
      inspect_item(items.shift)
    end
  end

  def <<(level)
    @items << level
  end

  def inspect_item(old)
    # level = eval(operation) / 3
    level = operation.(old)
    monkey = level % test_div == 0 ? monkey_true : monkey_false
    MONKEYS[monkey] << level
    @inspected += 1
  end
end

MONKEYS = read_input.map { Monkey.new(_1) }

500.times do |i|
  # print "#{i},"
  MONKEYS.each(&:🕵️)
end

ans = MONKEYS.map(&:inspected).sort.last(2).reduce(&:*)
puts "Answer 11.1: #{ans}"

ans2 = nil
puts "Answer 11.2: #{ans2}"
