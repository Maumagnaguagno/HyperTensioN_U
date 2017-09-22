require_relative '../../../Polygonoid/examples/search/Search'
require_relative '../../../Polygonoid/examples/circular/Circular'

module External
  extend self
  srand(0)
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
    @plan.size
  end
end