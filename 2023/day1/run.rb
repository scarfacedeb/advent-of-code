lines = File.readlines("input.txt")

sum = lines.map { |line|
  nums = line.scan(/\d/)
  (nums[0] + nums[-1]).to_i
}.sum

puts "Day 1.1: #{sum}"

NUMS = %w{one two three four five six seven eight nine}.map.with_index(1).to_h

lines = File.readlines("input.txt")
# lines = ["rzvlkjvone142oneightpv"]

sum = lines.map { |line|
  nums = {}

  NUMS.each do |num, i|
    line.gsub(num) { nums[Regexp.last_match.begin(0)] = i.to_s }
  end

  line.gsub(/\d/) { nums[Regexp.last_match.begin(0)] = _1.to_s }

  nums = nums.sort_by(&:first).map(&:last)
  (nums[0] + nums[-1]).to_i
}.sum

puts "Day 1.2: #{sum}"
