require "debug"

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n").slice_after("").map { _1.map(&:strip).reject(&:empty?) }
end

def parse_operation(line)
  _, oper, num = line.match(/Operation: new = old ([\+\*]) (\w+)/).to_a
  num = num.to_i unless num == "old"
  case oper
  when "*"
    if num == "old"
      ->(old) {
        val = old * old
        val > DENOM ? val % DENOM : val
      }
    else
      ->(old) {
        val = old * num
        val > DENOM ? val % DENOM : val
      }
    end
  when "+"
    if num == "old"
      ->(old) { old + old }
    else
      ->(old) { old + num }
    end
  end
end

def parse_condition(lines)
  test_div = lines.shift.match(/Test: divisible by (\d+)/)[1].to_i
  monkey_true = lines.shift.match(/If true: throw to monkey (\d+)/)[1].to_i
  monkey_false = lines.shift.match(/If false: throw to monkey (\d+)/)[1].to_i
  [
    ->(level) { level % test_div == 0 ? monkey_true : monkey_false },
    test_div
  ]
end

Monkey = Struct.new(:items, :inspected, :test_div, :procs, keyword_init: true)

def parse(lines)
  id = lines.shift.match(/Monkey (\d+):/)[1].to_i
  items = lines.shift.match(/items: (.*)/)[1].split(", ").map(&:to_i)
  operation = parse_operation(lines.shift)
  condition, test_div = parse_condition(lines)

  Monkey.new(
    items:,
    inspected: 0,
    test_div:,
    procs: [operation, condition]
  )
end

monkeys = read_input.map { parse(_1) }

# SIZES: [7, 3, 0, 0]
# INSPECTED: [5204, 4792, 199, 5192]
# Answer 11.2: 27019168

DENOM = monkeys.map(&:test_div).reduce(:*)

10000.times do |_i|
  monkeys.each do |m|
    operation, condition = m[:procs]
    m[:inspected] += m[:items].count

    while (level = m[:items].shift)
      level = operation.call(level)
      monkey = condition.call(level)
      monkeys[monkey][:items] << level
    end
  end
end

inspected = monkeys.map { _1[:inspected] }
puts "SIZES: #{monkeys.map(&:items).map(&:size)}"
puts "INSPECTED: #{inspected}"

ans = inspected.sort.last(2).reduce(&:*)
puts "Answer 11.2: #{ans}"
