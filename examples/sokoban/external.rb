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

  def find_deadlocks
    goal = Sokoban.state['goal']
    Sokoban.state['deadlock'] = deadlocks = []
    map = []
    Sokoban.state['wall'].each {|wall|
      wall.first =~ /^p(\d+)_(\d+)$/
      (map[$2.to_i] ||= [])[$1.to_i] = true
    }
    map[1..-2].each_with_index {|row,y|
      y += 1
      row[1..-2].each_with_index {|cell,x|
        if not cell and not goal.include?(p = ["p#{x += 1}_#{y}"]) and (map[y-1][x] or map[y+1][x]) and (map[y][x-1] or map[y][x+1])
          deadlocks << p
        end
      }
    }
  end

  def new_state(player)
    hash = 0
    i = 1
    Sokoban.state['box'].sort!.each {|b| hash += b.first[/^p(\d+_\d+)$/,1].to_i * (i *= 100)}
    if @visited.include?(hash += player[/^p(\d+_\d+)$/,1].to_i) then false
    else @visited[hash] = true
    end
  end
end