module External
  extend self

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
end