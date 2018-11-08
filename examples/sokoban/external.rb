module External
  extend self

  DIRS = [[1,0],[-1,0],[0,1],[0,-1]]

  @visited = {}

  def adjacent(from, to)
    from =~ /^p(\d+)_(\d+)$/
    x = $1.to_i
    y = $2.to_i
    clear = Sokoban.state['clear']
    DIRS.each {|dx,dy|
      if clear.include?([c = "p#{x+dx}_#{y+dy}"])
        to.replace(c)
        yield
      end
    }
  end

  def pushable(from, intermediate, to)
    from =~ /^p(\d+)_(\d+)$/
    x = $1.to_i
    y = $2.to_i
    box = Sokoban.state['box']
    clear = Sokoban.state['clear']
    DIRS.each {|dx,dy|
      if box.include?([b = "p#{x+dx}_#{y+dy}"]) and clear.include?([c = "p#{x+dx+dx}_#{y+dy+dy}"])
        intermediate.replace(b)
        to.replace(c)
        yield
      end
    }
  end

  def boxes_stored
    goal = Sokoban.state['goal']
    Sokoban.state['box'].all? {|p| goal.include?(p)}
  end

  def visited
    hash = 0
    i = 1
    Sokoban.state['box'].sort!.each {|b|
      b.first =~ /^p(\d+_\d+)$/
      hash += $1.to_i * (i *= 100)
    }
    Sokoban.state['player'][0][0] =~ /^p(\d+_\d+)$/
    if @visited.include?(hash += $1.to_i) then false
    else @visited[hash] = true
    end
  end
end