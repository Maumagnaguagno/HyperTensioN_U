# Levels are stored as strings, see http://www.sokobano.de/wiki/index.php?title=Level_format
[
"\
#####
#@$.#
#####",
"\
#####
# $.#
#@$.#
# $.#
#####",
"\
######
#.# @#
# #  #
#$ * #
#   ##
######",
"\
 ######
##    #
#   $ #
#  $$ #
### .#####
  ##.# @ #
   #.  $ #
   #. ####
   ####",
].each_with_index {|level,i|
  puts "Level #{i += 1}".center(47,'-'), level
  problem = "(defproblem pb#{i} sokoban\n  ("
  x = y = 0
  player = nil
  level.each_char {|c|
    new_line = false
    case c
    when '#' then problem << "\n    (wall p#{x}_#{y})"
    when '@' then player = "p#{x}_#{y}"
    when '+'
      problem << "\n    (goal p#{x}_#{y})"
      player = "p#{x}_#{y}"
    when '$' then problem << "\n    (box p#{x}_#{y})"
    when '*' then problem << "\n    (box p#{x}_#{y})\n    (goal p#{x}_#{y})"
    when '.' then problem << "\n    (clear p#{x}_#{y})\n    (goal p#{x}_#{y})"
    when ' ' then problem << "\n    (clear p#{x}_#{y})"
    when "\n"
      new_line = true
      x = 0
      y += 1
    end
    x += 1 unless new_line
  }
  problem << "\n  )\n  (\n    (solve #{player})\n  )\n)"
  IO.binwrite(File.expand_path("../pb#{i}.ujshop", __FILE__), problem)
}