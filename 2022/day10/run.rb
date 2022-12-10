require 'debug'

def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n")
end

class Noop
  attr_reader :cmd, :ticks

  def initialize(cmd)
    @cmd = cmd
    @ticks = 1
  end

  def run(reg) = reg
  def to_s = cmd
end

class Add
  attr_reader :cmd, :ticks, :reg_name, :value

  def initialize(cmd)
    @cmd = cmd
    @reg_name, @value = cmd.match(/add(\w) (-?\d+)/) { |m| [m[1], m[2].to_i] }
    @ticks = 2
  end

  def run(reg)
    reg + value
  end

  def to_s = cmd
end

def parse(cmd)
  case cmd
  when "noop" then Noop.new(cmd)
  when /add/ then Add.new(cmd)
  end
end

cmds = read_input.map { parse(_1) }

reg = 1
tick = 0

strenghts = []
crt = []
line = []

loop do
  cmd = cmds.shift

  cmd.ticks.times do
    tick += 1
    beam = (tick - 1) % 40

    if beam == 0 && tick > 2
      crt << line
      line = []
    end

    if beam.between?(reg - 1, reg + 1)
      line << "#"
    else
      line << " "
    end

    if (tick - 20) % 40 == 0
      strenghts << (tick * reg)
    end
    # puts "#{cmd} T#{tick} #{reg - 1} < #{beam} < #{reg + 1} => #{line.join}"
  end

  reg = cmd.run(reg)

  break if cmds.empty?
end

crt << line

ans = strenghts.sum
puts "Answer 10.1: #{ans}"

ans2 = crt.map { _1.join("") }.join("\n")
puts "Answer 10.2: "
puts ans2
