require 'benchmark'

def read_input
  file = $all ? 'input.txt' : 'example.txt'
  input = File.read(ARGV.last || file).split("\n")
  input.map { _1.split('-').map(&:to_sym) }
end

p Benchmark.measure {

input = read_input
paths = input.group_by(&:first).transform_values { _1.map(&:last) }
input.group_by(&:last).transform_values { _1.map(&:first) }.each do |key, list|
  paths.key?(key) ? paths[key] += list : paths[key] = list
end

def traverse(paths, travelled, from, to, stack = 0)
  travelled = travelled + [to]
  # puts "#{from}->#{to} in #{travelled} L#{stack}"
  return travelled if to == :end

  visited_twice = travelled.filter { _1 =~ /[a-z]+/ }.tally.values.any? { _1 > 1 }

  paths[to].reject { _1 == :start }.flat_map {
    next if travelled.include?(_1) && _1 !~ /[A-Z]+/ && visited_twice
    traverse(paths, travelled, to, _1, stack + 1)
  }.compact
end

navs = paths[:start].flat_map { |to|
  traverse(paths, [:start], :start, to).slice_when { _1 == :end }.to_a
}

ans = navs.count
puts "Answer 12: #{ans}"

}.total * 1000
