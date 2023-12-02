input = File.readlines(ENV["FULL"] == "1" ? "input.txt" : "example.txt").map(&:strip)
bag = {
  red: 12,
  green: 13,
  blue: 14
}

games = input.map { |line|
  _, game, sets = line.split(/Game (\d+): /)
  game = game.to_i
  sets = sets.split(";").map { |s| s.split(",").map { n, clr = _1.split(" "); [clr.to_sym, n.to_i] }.to_h }

  [game, sets]
}.to_h

max = games.transform_values { |sets|
  sets.reduce({ red: 0, green: 0, blue: 0 }) { |h, set|
    h[:red] = [set[:red].to_i, h[:red]].max
    h[:green] = [set[:green].to_i, h[:green]].max
    h[:blue] = [set[:blue].to_i, h[:blue]].max
    h
  }
}

possible = max.select { |_, set|
  set[:red] <= bag[:red] &&
    set[:green] <= bag[:green] &&
    set[:blue] <= bag[:blue]
}

res = possible.map(&:first).sum

puts "Day 2.1: #{res}"

powers = max.values.map { _1.values.reduce(:*) }
res2 = powers.sum

puts "Day 2.2: #{res2}"
# binding.irb
