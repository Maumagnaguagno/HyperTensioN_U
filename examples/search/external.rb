require_relative '../../../Polygonoid/examples/search/Search'

module External
  extend self

  @symbolic_geometric = {
    'start' => Point.new(80,50),
    'goal'  => Point.new(15,50)
  }
  @pos_counter = 0

  ANGLE = 10
  ENVIRONMENT = [
    Polygon.new(
      Point.new(35,30),
      Point.new(50,30),
      Point.new(50,50),
      Point.new(60,50),
      Point.new(55,70),
      Point.new(35,70)
    )
  ]

  def visible(from, to)
    a = @symbolic_geometric[from]
    b = @symbolic_geometric[to]
    visible?(a, b, ENVIRONMENT)
  end

  def near(from, to)
    a = @symbolic_geometric[from]
    b = @symbolic_geometric[to]
    nearby(a, b, ANGLE, ENVIRONMENT) {|pos|
      symbol = @symbolic_geometric.key(pos)
      unless symbol
        symbol = "pos#{@pos_counter}"
        @pos_counter += 1
        @symbolic_geometric[symbol] = pos
      end
      to.replace(symbol)
      yield
    }
  end
end