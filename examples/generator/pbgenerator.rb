tanks = ''
1.upto(20) {|i|
  tanks << "\n    (available tank#{i})"
  File.binwrite("#{__dir__}/pb#{i}.ujshop",
    "(defproblem pb#{i} generator\n  (
    (generator gen)
    (function (fuellevel gen) #{1000 - i * 20})
    (function (capacity gen) 1000)#{tanks}\n  )\n  (
    (refuel-and-generate gen)\n  )\n)"
  )
}