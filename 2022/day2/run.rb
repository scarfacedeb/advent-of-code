
SCORES = {
  A: 1,
  B: 2,
  C: 3,
  X: 1,
  Y: 2,
  Z: 3
}

MAP = {
  X: :A,
  Y: :B,
  Z: :C
}

OUTCOMES = {
  X: 0,
  Y: 3,
  Z: 6
}

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  File.read(ARGV.last || file).split("\n").map { _1.split(" ").map(&:to_sym) }
end

def play(you, opponent)
  opponent = MAP[opponent]
  return 3 if you == opponent

  case [opponent, you]
  in [:A, :B] then 0
  in [:A, :C] then 6
  in [:B, :A] then 6
  in [:B, :C] then 0
  in [:C, :A] then 0
  in [:C, :B] then 6
  end
end

def round(you, opponent)
  play(you, opponent) + SCORES[opponent]
end

def guided_play(opponent, outcome)
  return opponent if outcome == :Y

  case [opponent, outcome]
  in [:A, :X] then :C
  in [:A, :Z] then :B
  in [:B, :X] then :A
  in [:B, :Z] then :C
  in [:C, :X] then :B
  in [:C, :Z] then :A
  end
end

def guided_round(opponent, outcome)
  OUTCOMES[outcome] + SCORES[guided_play(opponent, outcome)]
end


input = read_input
scores = input.map { round(_1, _2) }
ans = scores.sum
puts "Answer 2.1: #{ans}"

scores2 = input.map { guided_round(_1, _2) }
ans = scores2.sum
puts "Answer 2.2: #{ans}"
