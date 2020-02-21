module External
  extend self

  DIRS = [[1,0],[-1,0],[0,1],[0,-1]]

  def adjacent(from, to, goal)
    from =~ /^p(\d+)_(\d+)$/
    x = $1.to_i
    y = $2.to_i
    goal =~ /^p(\d+)_(\d+)$/
    gx = $1.to_i
    gy = $2.to_i
    clear = Map.state['clear']
    candidates = []
    DIRS.each {|dx,dy|
      if clear.include?([k = "p#{dx += x}_#{dy += y}"])
        candidates << [dx, dy, k]
      end
    }
    candidates.sort_by! {|i,j,k| Math.hypot(i - gx, j - gy)}.each {|i,j,k|
      to.replace(k)
      yield
    }
  end
end