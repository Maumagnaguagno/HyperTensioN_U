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
  player = valid = nil
  level.each_char {|c|
    case c
    when '#'
      problem << "\n    (wall p#{x}_#{y})"
      valid = true
    when '@' then player = "p#{x}_#{y}"
    when '+'
      problem << "\n    (storage p#{x}_#{y})"
      player = "p#{x}_#{y}"
    when '$' then problem << "\n    (box p#{x}_#{y})"
    when '*' then problem << "\n    (box p#{x}_#{y})\n    (storage p#{x}_#{y})"
    when '.' then problem << "\n    (clear p#{x}_#{y})\n    (storage p#{x}_#{y})"
    when ' ' then problem << "\n    (clear p#{x}_#{y})" if valid
    when "\n"
      x = -1
      y += 1
      valid = false
    end
    x += 1
  }
  problem << "\n  )\n  (\n    (solve #{player})\n  )\n)"
  IO.binwrite("#{__dir__}/pb#{i}.ujshop", problem)
}