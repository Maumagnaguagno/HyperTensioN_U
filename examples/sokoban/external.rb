module External
  extend self

  @memory = {}

  def adjacent(from, to)
    from =~ /^p(\d+)_(\d+)$/
    x = $1.to_i
    y = $2.to_i
    to.replace("p#{x+1}_#{y}")
    yield
    to.replace("p#{x-1}_#{y}")
    yield
    to.replace("p#{x}_#{y+1}")
    yield
    to.replace("p#{x}_#{y-1}")
    yield
  end

  def pushable(from, intermediate, to)
    intermediate =~ /^p(\d+)_(\d+)$/
    x = $1.to_i
    y = $2.to_i
    from.replace(x1 = "p#{x-1}_#{y}")
    to.replace(x2 = "p#{x+1}_#{y}")
    yield
    from.replace(x2)
    to.replace(x1)
    yield
    from.replace(y1 = "p#{x}_#{y-1}")
    to.replace(y2 = "p#{x}_#{y+1}")
    yield
    from.replace(y2)
    to.replace(y1)
    yield
  end

  def boxes_stored
    goal = Sokoban.state['goal']
    Sokoban.state['box'].all? {|p| goal.include?(p)}
  end

  def new_state
    hash = 0
    i = 1
    Sokoban.state['box'].sort!.each {|b|
      b.first =~ /^p(\d+_\d+)$/
      i *= 100
      hash += $1.to_i * i
    }
    Sokoban.state['player'][0][0] =~ /^p(\d+_\d+)$/
    if @memory.include?(hash += $1.to_i) then false
    else @memory[hash] = true
    end
  end
end