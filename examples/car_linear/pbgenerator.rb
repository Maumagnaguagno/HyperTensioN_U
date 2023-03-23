[
  [0,0,0,-10,10,10,999.5,1010.5],
  [0,0,0,-1,1,10,29.5,30.5],
  [0,0,0,-2,2,10,29.5,30.5],
  [0,0,0,-3,3,10,29.5,30.5],
  [0,0,0,-4,4,10,29.5,30.5],
  [0,0,0,-5,5,10,29.5,30.5],
  [0,0,0,-6,6,10,29.5,30.5],
  [0,0,0,-7,7,10,29.5,30.5],
  [0,0,0,-8,8,10,29.5,30.5],
].each_with_index {|(d,v,a,mina,maxa,maxs,minp,maxp),i|
  File.binwrite("#{__dir__}/pb#{i}.ujshop",
    "(defproblem pb#{i} car_linear\n  (
    (function d #{d})
    (function v #{v})
    (function a #{a})
    (function min_acceleration #{mina})
    (function max_acceleration #{maxa})
    (function max_speed #{maxs})
    (protect_axiom speed_limit)\n  )\n  (
    (forward #{minp} #{maxp})\n  )\n)"
  )
}