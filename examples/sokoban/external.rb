module Sokoban

  DIRS = [[1,0],[-1,0],[0,1],[0,-1]]

  def problem(state, tasks, *args)
    # Find deadlocks
    storage = state['storage']
    deadlocks = state['deadlock'] = []
    map = []
    state['wall'].each {|wall,|
      x, y = wall.delete_prefix('p').split('_')
      (map[y.to_i] ||= [])[x.to_i] = true
    }
    map[1..-2].each_with_index {|row,y|
      y += 1
      row[1..-2].each_with_index {|cell,x|
        if not (cell or storage.include?(p = ["p#{x += 1}_#{y}"])) and (map[y-1][x] or map[y+1][x]) and (row[x-1] or row[x+1])
          deadlocks << p
        end
      }
    }
    # Visit initial position
    @visited = Hash.new {|h,k| h[k] = false; true}
    @visited[tasks[0][1].hash ^ state['box'].sort!.hash]
    super
  end

  def adjacent(from, to)
    x, y = from.delete_prefix('p').split('_')
    x = x.to_i
    y = y.to_i
    clear = @state['clear']
    DIRS.each {|dx,dy|
      if clear.include?([c = "p#{x+dx}_#{y+dy}"])
        to.replace(c)
        yield
      end
    }
  end

  def pushable(from, intermediate, to)
    x, y = from.delete_prefix('p').split('_')
    x = x.to_i
    y = y.to_i
    box = @state['box']
    clear = @state['clear']
    DIRS.each {|dx,dy|
      if box.include?([b = "p#{x+dx}_#{y+dy}"]) and clear.include?([c = "p#{x+dx+dx}_#{y+dy+dy}"])
        intermediate.replace(b)
        to.replace(c)
        yield
      end
    }
  end

  def boxes_stored
    storage = @state['storage']
    @state['box'].all? {|p| storage.include?(p)}
  end

  def new_state(player)
    @visited[player.hash ^ @state['box'].sort!.hash]
  end
end