require 'benchmark'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file).split("\n")
end

def draw(known)
  pattern = File.read('digits.txt')

  coords = Hash.new('?').merge(known)
  'a'.upto('g').each do |l|
    pattern.gsub!(l, "<#{l}>")
  end

  'a'.upto('g').each do |l|
    pattern.gsub!("<#{l}>", coords[l.to_sym])
  end

  puts pattern
end

lines = read_input.map { |l| l.split(' | ').map { _1.split(' ') } }

ans =
  lines.reduce(0) { |acc, line|
    _digits, output = line
    tally = output.map(&:size).tally
    acc += tally.slice(*[2,3,4,7]).values.sum
  }

puts "Answer 8.1: #{ans}"

ans2 =
  lines.map { |line|
    digits, output = line
    sizes = digits.group_by(&:size)


    one = sizes[2].first.chars
    seven = sizes[3].first.chars
    four = sizes[4].first.chars
    eight = sizes[7].first.chars

    top = (seven - one).first
    bottom_right = sizes[6].map(&:chars).map { |t| t & one}.find(&:one?).first
    top_right = (one - [bottom_right]).first

    top_left_and_middle = four - one
    middle = sizes[5].map(&:chars).map { |t| t & top_left_and_middle }.find(&:one?).first
    top_left = (top_left_and_middle - [middle]).first

    bottom_left_and_bottom = sizes[5].map(&:chars).map { |t| t - [top, top_right, top_left, middle, bottom_right]  }
    bottom = bottom_left_and_bottom.find(&:one?).first
    bottom_left = (bottom_left_and_bottom.find { _1.size == 2 } - [bottom]).first

    decoded = [
      [top_left, top, top_right, bottom_right, bottom, bottom_left], # 0
      one,
      [top, top_right, middle, bottom_left, bottom], # 2
      [top, top_right, middle, bottom_right, bottom], # 3
      four,
      [top, top_left, middle, bottom_right, bottom], # 5
      [top, top_left, middle, bottom_right, bottom, bottom_left], # 6
      seven,
      eight,
      [top_left, top, top_right, middle, bottom_right, bottom] # 9
    ].map.with_index { |l, i| [l.sort.join, i] }.to_h

    output_num = output.map { _1.chars.sort.join }.map { decoded[_1] }.join.to_i
    output_num
  }.sum

puts "Answer 8.2: #{ans2}"
