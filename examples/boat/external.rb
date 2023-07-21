require_relative '../../../Polygonoid/Polygonoid'

module Boat

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
    cos = Math.cos(direction)
    sin = Math.sin(direction)
    x = pos.x + magnitude * cos
    y = pos.y + magnitude * sin
    # Expected path
    newpos.replace(symbol(Point.new(x, y)))
    yield
    # Overshoot error (1 magnitude)
    newpos.replace(symbol(Point.new(x + cos, y + sin)))
    yield
  end
end