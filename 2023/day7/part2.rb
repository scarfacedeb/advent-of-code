require "debug"

def read_input
  File.readlines(ENV["FULL"] == "1" ? "input.txt" : "example.txt").map(&:strip)
end

def parse(input)
  input.map { |line|
    Hand.new(*line.split)
  }
end

CARDS = %i{A K Q X T 9 8 7 6 5 4 3 2 J}.reverse.map.with_index(1).to_h.freeze

class Card
  include Comparable

  attr_reader :symbol, :value

  def initialize(symbol)
    @symbol = symbol.to_sym
    @value = CARDS.fetch(@symbol)
  end

  def <=>(other)
    value <=> other.value
  end

  def to_s
    symbol.to_s
  end
  alias_method :inspect, :to_s
end

COMBINATIONS = {
  {} => 0,
  { 2 => 1 } => 60,
  { 2 => 2 } => 120,
  { 3 => 1 } => 180,
  { 3 => 1, 2 => 1 } => 240,
  { 4 => 1 } => 300,
  { 5 => 1 } => 360
}.freeze

class Hand
  include Comparable

  attr_reader :cards, :bid

  def initialize(cards, bid)
    @cards = cards.chars.map { Card.new(_1) }
    @bid = bid.to_i
  end

  def to_s
    "#{cards.map(&:symbol).join} #{bid}"
  end

  def combinations
    # @combinations ||= cards.map(&:symbol).tally.values.reject { _1 == 1 }.tally
    tally = cards.map(&:value).tally
    jokers = tally.delete(1)
    if jokers
      top_card = tally.sort_by(&:reverse).reverse.dig(0, 0)
      top_card ||= CARDS[:A]
      tally[top_card] = tally.fetch(top_card, 0) + jokers
    end
    tally.values.reject { _1 == 1 }.tally
  end

  def weight
    @weight ||= COMBINATIONS.fetch(combinations)
  end

  def weighted_cards
    @weighted_cards ||= [weight, *cards.map(&:value)]
  end

  def <=>(other)
    weighted_cards <=> other.weighted_cards
  end
end

input = read_input
hands = parse(input).sort

bids = hands.map.with_index(1) { |hand, rank| hand.bid * rank }

res2 = bids.sum
puts "Day 7.2: #{res2}"

binding.irb
