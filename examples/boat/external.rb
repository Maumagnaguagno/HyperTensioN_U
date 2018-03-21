require_relative '../../../Polygonoid/Polygonoid'

module External
  extend self

  attr_reader :pi

  @symbol_object = {'start' => Point.new(0,0)}
  @pos_counter = 0
  @pi = Math::PI

  def symbol(object)
    symbol = @symbol_object.key(object) or @symbol_object[symbol = "pos#{@pos_counter += 1}"] = object
    symbol
  end

  def advance(pos, magnitude, direction, newpos)
    # TODO add wind, current and error in magnitude and direction
    pos = @symbol_object[pos]
    magnitude = magnitude.to_f
    direction = direction.to_f
    x = pos.x + magnitude * Math.cos(direction)
    y = pos.y + magnitude * Math.sin(direction)
    # Expected path
    newpos.replace(symbol(Point.new(x,y)))
    yield
    # Overshoot error
    magnitude += 1
    x = pos.x + magnitude * Math.cos(direction)
    y = pos.y + magnitude * Math.sin(direction)
    newpos.replace(symbol(Point.new(x,y)))
    yield
  end
end