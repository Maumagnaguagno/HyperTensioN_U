require_relative '../../../Polygonoid/examples/search/Search'
require_relative '../../../Polygonoid/examples/circular/Circular'

CLOCK = 'clock'
COUNTER = 'counter'

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

  def visible(from, to, a, b)
    visible?(Line.new(@symbol_object[from], @symbol_object[to]), CIRCLES, @symbol_object[a], @symbol_object[b])
  end

  def bitangent(pos, from, to, in_dir_symbol, out_dir_symbol, out_circle)
    each_bitangent(@symbol_object[pos], in_dir_symbol, CIRCLES) {|c,line,out_dir|
      from.replace(symbol(line.from))
      to.replace(symbol(line.to))
      out_dir_symbol.replace(out_dir)
      out_circle.replace(symbol(c))
      yield
    }
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