# require "debug"

def read_input
  File.readlines(ENV["FULL"] == "1" ? "input.txt" : "example.txt").map(&:strip)
end

def parse(input)
  seq = input.shift.chars
  input.shift
  nodes = input.map { |line|
    _, node, left, right = line.match(/(\w+) = \((\w+), (\w+)\)/).to_a
    [node, { "L" => left, "R" => right }]
  }.to_h
  [seq, nodes]
end

input = read_input
seq, nodes = parse(input)

dest = "AAA"
steps = 0
seqc = seq.cycle
until dest == "ZZZ"
  dest = nodes[dest][seqc.next]
  steps += 1
end

res = steps
puts "Day 8.1: #{res}"

# == PART 2 ==

# dests = nodes.keys.grep(/A$/)
# z_nodes = nodes.keys.grep(/Z$/).to_set
# z_count = 0
# a_count = dests.count
# steps = 0

# until z_count == a_count
#   step = seq.next
#   # z_count = 0
#   dests = dests.map { |node|
#     nodes[node][step]
#     # z_count += 1 if z_nodes.include?(dest)
#     # dest
#   }
#   z_count = dests.count { z_nodes.include?(_1) }
#   steps += 1
#   break if steps >= 1_000_000
#   # puts steps
# end

Node = Struct.new(:name, :L, :R, :start, :finish)

inodes = nodes.map { |node, _| [node, Node.new(node)] }.to_h
inodes.each do |name, inode|
  dir = nodes[name]
  inode.L = inodes[dir["L"]]
  inode.R = inodes[dir["R"]]
  inode.start = name.end_with?("A")
  inode.finish = name.end_with?("Z")
end

# finished = false
# steps = 0
# dests = inodes.values.select(&:start)

# until finished
#   step = seq.next
#   dests = dests.map { |node| node.send(step) }
#   finished = dests.all?(&:finish)
#   # break if steps > 1_000_000
#   steps += 1
#   # puts "#{steps}: #{dests.select(&:finish).map(&:name)} / #{dests.reject(&:finish).map(&:name)}"
# end

start_nodes = inodes.values.select(&:start)
counts = start_nodes.map { |node|
  dest = node
  steps = 0
  seqc = seq.cycle

  until dest.finish
    dest = dest.send(seqc.next)
    steps += 1
  end

  steps / seq.size
}

counts << seq.size
res2 = counts.reduce(&:lcm)

puts "Day 8.2: #{res2}"

# binding.irb
