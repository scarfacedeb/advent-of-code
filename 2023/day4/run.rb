def read_input
  File.readlines(ENV["FULL"] == "1" ? "input.txt" : "example.txt").map(&:strip)
end

def parse(input)
  input.map { |line|
    _, no, win, current = line.match(/Card +(\d+): +((?:\d+ *)+) +\| +((:?\d+ *)+)/).to_a
    Card.new(no, win, current)
  }
end

class Card
  attr_reader :no, :winning, :current

  def initialize(no, winning, current)
    @no = no.to_i
    @winning = parse(winning)
    @current = parse(current)
  end

  def matching
    @matching ||= winning & current
  end

  def length
    matching.length
  end

  def points
    return 0 if matching.empty?

    2**(matching.length - 1)
  end

  private

  def parse(nums)
    nums.split.map(&:to_i)
  end
end

input = read_input
cards = parse(input)

res = cards.map(&:points).sum
puts "Day 4.1: #{res}"

tally = cards.map(&:no).tally

cards.each do |card|
  extra_cards = (card.no + 1).upto(card.no + card.length).to_a
  extra_cards *= tally.fetch(card.no, 1)
  extra_cards.each { |no| tally[no] += 1 }
  # p "Card: #{card.no} #{extra_cards}"
  # p tally
end

res2 = tally.values.sum
puts "Day 4.2: #{res2}"

# binding.irb
