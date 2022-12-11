# require 'debug'

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").slice_after("").map { _1.map(&:strip).reject(&:empty?) }
end

class Monkey
  attr_reader :id, :items, :operation, :test_div, :monkey_true, :monkey_false, :inspected
  attr_accessor :monkeys

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
    @raw_items = @items
    @items = @items.map { calc(_1) }
  end

  def parse_operation(line)
    _, oper, num = line.match(/Operation: new = old ([\+\*]) (\w+)/).to_a
    @raw_operation = "#{oper} #{num}"
    num = num.to_i unless num == "old"
    case oper
    when "*"
      if num == "old"
        -> (old) { old * old }
      else
        -> (old) { old * num }
      end
    when "+"
      if num == "old"
        -> (old) { old + old }
      else
        -> (old) { old + num }
      end
    end
  end

  def to_s
    "M#{id}: #{@raw_items} #{@raw_operation}"
  end

  def <<(level)
    @raw_items << level
    @items << calc(level)
  end

  def calc(old)
    operation.(old)
  end

  def concat(levels)
    @items.concat levels
  end

  def inspect_items
    items.each { inspect_item(_1) }
    @items = []
    @raw_items = []
    # monkeys.group_by(&:first).each do |monkey, items|
    #   monkeys[monkey].concat items.map(&:last)
    # end
  end

  alias_method :🕵️, :inspect_items

  def inspect_item(level)
    @inspected += 1
    # level = operation.(old)
    monkey = level % test_div == 0 ? monkey_true : monkey_false
    monkeys[monkey] << level
  end
end

monkeys = read_input.map { Monkey.new(_1) }
monkeys.each { _1.monkeys = monkeys }

puts monkeys

350.times do |i|
  monkeys.each(&:inspect_items)
  # puts "=== #{i} ==="
  # puts monkeys
end

inspected = monkeys.map(&:inspected)
puts "SIZES: #{monkeys.map(&:items).map(&:size)}"
puts "INSPECTED: #{inspected}"

ans = inspected.sort.last(2).reduce(&:*)
puts "Answer 11.2: #{ans}"
