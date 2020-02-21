require_relative '../../../Map_generator/Mapgen'
require_relative '../../../HyperTensioN/examples/experiments/Grid'

width = height = (ARGV.first || 5).to_i # 2 * N + 1
room_size = 4
start = 'p1_1'
goal = "p#{(width << 1) - 1}_#{(height << 1) - 1}"

20.times {|seed|
  srand(seed)
  map = Mapgen.maze_division(width, height, room_size)
  map = Mapgen.wall_to_tile(map)
  mapdata = ["(at agent #{start})"]
  map.each_with_index {|row,y| row.each_with_index {|c,x| mapdata << "(clear p#{x}_#{y})" if c == 0}}
  abort "Problem #{seed} with impossible start #{start}" unless mapdata.include?("(clear #{start})")
  mapdata.delete("(clear #{start})")
  abort "Problem #{seed} with impossible goal #{goal}" unless mapdata.include?("(clear #{goal})")
  mapdata.concat(Grid.generate(101,101).map! {|a,b| "(adjacent #{a} #{b})"})
  IO.binwrite(File.expand_path("../pb#{seed}.ujshop", __FILE__),
    "(defproblem pb#{seed} maze\n  (
    #{mapdata.join("\n    ")}\n  )\n  (
    (forward agent #{goal})\n  )\n)"
  )
}