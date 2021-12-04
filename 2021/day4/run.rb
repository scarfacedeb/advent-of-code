require "benchmark"

def read_input
  File.read(($input || ARGV.last || "example") + ".txt").split("\n")
end

input = read_input
game = input.shift.split(",").map(&:to_i)

boards = input.each_slice(6).map { |b| b.reject(&:empty?).map { |r| r.split(" ").map(&:to_i) } }

index = boards.map.with_index.reduce(Hash.new { |h, k| h[k] = [] }) { |acc, (b, b_i)|
  b.each_with_index { |r, i| r.each_with_index { |n, j| acc[n] << [b_i, i, j] } }
  acc
}

def bingo!(boards, game, index, marks)
  first_win = nil
  last_win = nil
  b_in_game = boards.count.times.to_a

  game.each do |num|
    index[num].group_by(&:first).select { |b_i, _| b_in_game.include?(b_i) }.each { |b_i, coords|
      marks[b_i] += coords.map { _1.tap(&:shift) }

      i_win = marks[b_i].group_by(&:first).find { |i, cols| cols.size == 5 }&.first
      j_win = marks[b_i].group_by(&:last).find { |j, rows| rows.size == 5 }&.first
      # puts "b_i=#{b_i} num=#{num} i_win=#{i_win} j_win=#{j_win}"
      next unless i_win || j_win

      first_win ||= [b_i, num]
      last_win = [b_i, num]
      b_in_game.delete(b_i)
      return [first_win, last_win] if b_in_game.empty?
    }
  end

  raise 'SAD TROMBONE 🎺'
end

def calc_answer(win, boards, marks)
  b_win, n_win = win
  board = boards[b_win]
  # binding.pry
  marks[b_win].each { |i, j| board[i][j] = 0 }

  n_win * board.flatten.sum
end

marks = boards.count.times.map { |b_i| [b_i, []] }.to_h

first_win, last_win = bingo!(boards, game, index, marks)

ans1 = calc_answer(first_win, boards, marks)
ans2 = calc_answer(last_win, boards, marks)

puts "Answer 4.1: #{ans1} (#{first_win})"
puts "Answer 4.2: #{ans2} (#{last_win})"
