require_relative '../../../Polygonoid/examples/search/Search'

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

  def advance(pos, angle, amount, newpos)
    # TODO add wind, current and error in amount and angle
    pos = @symbol_object[pos]
    angle = angle.to_f
    amount = amount.to_f
    x = pos.x + amount * Math.cos(angle)
    y = pos.y + amount * Math.sin(angle)
    # Expected path
    newpos.replace(symbol(Point.new(x,y)))
    yield
    # Overshoot error
    amount += 1
    x = pos.x + amount * Math.cos(angle)
    y = pos.y + amount * Math.sin(angle)
    newpos.replace(symbol(Point.new(x,y)))
    yield
  end
end