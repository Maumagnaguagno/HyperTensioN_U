require_relative '../../../Polygonoid/examples/search/Search'
require_relative '../../../Polygonoid/examples/circular/Circular'

module External
  extend self
  srand(0)
  CLOCK = 'clock'
  COUNTER = 'counter'
  CIRCLES = Array.new(100) {Circle.new(50 + rand(1000), 50 + rand(1000), 5 + rand(50))}

  @symbol_object = {
    'start' => Circle.new(0,80,0),
    'goal'  => Circle.new(1000,1000,0)
  }
  @pos_counter = 0

  def symbol(object)
    symbol = @symbol_object.key(object) or @symbol_object[symbol = "pos#{@pos_counter += 1}"] = object
    symbol
  end

  def search_circular(agent, start, goal)
    @plan = search(@symbol_object[start], @symbol_object[goal], CIRCLES)
    @plan = @plan.map! {|i| symbol(i)} if @plan
  end

  def plan_position(index)
    @plan[index.to_i]
  end

  def plan_size
    @plan.size.to_f.to_s
  end

  def closest(circle, to, out_circle, in_dir, out_dir, goal)
    reachable = []
    g = @symbol_object[goal]
    circles_sort = CIRCLES.sort_by {|c| center_distance(c, g)}
    each_bitangent(@symbol_object[circle], in_dir == CLOCK, circles_sort) {|c,l,d|
      out_circle.replace(symbol(c))
      to.replace(symbol(l.to))
      out_dir.replace(d ? CLOCK : COUNTER)
      yield
    }
  end

  def visible(point, circle, goal)
    g = @symbol_object[goal]
    visible?(Line.new(@symbol_object[point], g), CIRCLES, @symbol_object[circle], g)
  end
end