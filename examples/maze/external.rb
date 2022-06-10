module External
  extend self

  DIRS = [[1,0],[-1,0],[0,1],[0,-1]]

  @visited = {}

  def adjacent(from, to, goal)
    from =~ /^p(\d+)_(\d+)$/
    x = $1.to_i
    y = $2.to_i
    goal =~ /^p(\d+)_(\d+)$/
    gx = $1.to_i
    gy = $2.to_i
    clear = Maze.state['clear']
    candidates = []
    DIRS.each {|dx,dy|
      if clear.include?([k = "p#{dx += x}_#{dy += y}"])
        candidates << [Math.hypot(dx - gx, dy - gy), k]
      end
    }
    candidates.sort!.each {|k|
      to.replace(k.last)
      yield
    }
  end

  def adjacent_not_visited(agent, from, to, goal)
    from =~ /^p(\d+)_(\d+)$/
    x = $1.to_i
    y = $2.to_i
    goal =~ /^p(\d+)_(\d+)$/
    gx = $1.to_i
    gy = $2.to_i
    clear = Maze.state['clear']
    candidates = []
    DIRS.each {|dx,dy|
      if clear.include?([k = "p#{dx += x}_#{dy += y}"]) and not @visited.include?([agent, k])
        candidates << [Math.hypot(dx - gx, dy - gy), k]
      end
    }
    candidates.sort!.each {|k|
      to.replace(k.last)
      yield
    }
  end

  def visit(agent, from)
    @visited[[agent, from]] = nil
    true
  end

  def unvisit(agent, from)
    @visited.delete([agent, from])
    true
  end
end