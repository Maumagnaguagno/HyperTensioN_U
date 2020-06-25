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
    case c
    when '#' then problem << "\n    (wall p#{x}_#{y})"
    when '@' then player = "p#{x}_#{y}"
    when '+'
      problem << "\n    (storage p#{x}_#{y})"
      player = "p#{x}_#{y}"
    when '$' then problem << "\n    (box p#{x}_#{y})"
    when '*' then problem << "\n    (box p#{x}_#{y})\n    (storage p#{x}_#{y})"
    when '.' then problem << "\n    (clear p#{x}_#{y})\n    (storage p#{x}_#{y})"
    when ' ' then problem << "\n    (clear p#{x}_#{y})"
    when "\n"
      x = -1
      y += 1
    end
    x += 1
  }
  problem << "\n  )\n  (\n    (solve #{player})\n  )\n)"
  IO.binwrite(File.expand_path("../pb#{i}.ujshop", __FILE__), problem)
}