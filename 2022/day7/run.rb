def read_input
  file = $all ? "input.txt" : "example.txt"
  File.read(ARGV.last || file).split("\n")
end

DirStruct = Struct.new(:name, :parent, :ls) do
  def size
    ls.sum(&:size)
  end

  def dir? = true
  def file? = false
end

FileStruct = Struct.new(:dir, :name, :size) do
  def dir? = false
  def file? = true
end

def parse(line, current_dir = nil)
  case line.split(" ")
  in ["$", "cd", ".."]
    current_dir.parent
  in ["$", "cd", "/"]
    DirStruct.new("/", current_dir, [])
  in ["$", "cd", dir]
    current_dir.ls.find { _1.name == dir }
  in ["$", "ls"]
    current_dir
  in ["dir", dir]
    current_dir.ls << DirStruct.new(dir, current_dir, [])
    current_dir
  in [size, filename]
    current_dir.ls << FileStruct.new(current_dir, filename, size.to_i)
    current_dir
  end
end

def find_dirs(tree)
  dirs = tree.ls.filter(&:dir?)
  dirs + dirs.flat_map { find_dirs(_1) }
end

input = read_input

tree = parse(input.shift, tree) until input.empty?
tree = tree.parent while tree.parent

dirs = (find_dirs(tree) << tree).sort_by(&:size)
ans = dirs.filter { _1.size < 100_000 }.map(&:size).sum

puts "Answer 6.1: #{ans}"

free = 70_000_000 - tree.size
required = 30_000_000 - free

ans2 = dirs.find { _1.size >= required }.size

puts "Answer 6.2: #{ans2}"
