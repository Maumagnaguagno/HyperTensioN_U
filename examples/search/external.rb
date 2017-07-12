require_relative '../../../Polygonoid/examples/search/Search2'

module External
  extend self

  @symbol_object = {
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

  def symbol(object)
    @symbol_object[symbol = "pos#{@pos_counter += 1}"] = object unless symbol = @symbol_object.key(object)
    symbol
  end

  def visible(from, to)
    visible?(@symbol_object[from], @symbol_object[to], ENVIRONMENT)
  end

  def near(from, to, place)
    nearby(@symbol_object[from], @symbol_object[to], ANGLE, ENVIRONMENT) {|pos|
      place.replace(symbol(pos))
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