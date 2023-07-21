require_relative '../../../Polygonoid/examples/search/Linear'

module Search

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
  ANGLE = 10

  @symbol_object = {
    'start' => Point.new(80,50),
    'goal'  => Point.new(15,50)
  }
  @pos_counter = 0

  def symbol(object)
    symbol = @symbol_object.key(object) or @symbol_object[symbol = "pos#{@pos_counter += 1}"] = object
    symbol
  end

  def visible(from, to)
    visible?(@symbol_object[from], @symbol_object[to], ENVIRONMENT)
  end

  def arc(from, to, arc_to)
    Linear.line_to_arc(@symbol_object[from], @symbol_object[to], ANGLE, ENVIRONMENT) {|pos|
      arc_to.replace(symbol(pos))
      yield
    }
  end

  def visible_vertex(from, vertex)
    a = @symbol_object[from]
    ENVIRONMENT.each {|polygon|
      polygon.vertices.each {|v|
        if visible?(a, v, ENVIRONMENT)
          vertex.replace(symbol(v))
          yield
        end
      }
    }
  end
end