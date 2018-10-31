tanks = ''
1.upto(19) {|i|
  tanks << "\n    (tank tank#{i})  (available tank#{i})"
  IO.binwrite("pb#{i}.ujshop", "(defproblem pb#{i} generator
  (
    (generator gen)
    (function (fuellevel gen) #{1000 - i * 20})
    (function (capacity gen) 1000)#{tanks}
  )
  (
    (refuel-and-generate gen)
  )\n)")
}