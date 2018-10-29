require 'forwardable'
require_relative '../../../HyperTensioN/examples/experiments/Function'
require_relative '../../../HyperTensioN/examples/experiments/Debug'

module Plant_watering
  prepend Function, Debug

  def problem(state, *args)
    function = state[:function] = {}
    state.delete('function').each {|f,v| function[f] = v.to_f}
    super(state, *args)
  end

  def adjacent(x, y, nx, ny)
    x = x.to_i
    y = y.to_i
    f = @state[:function]
    minx = f['minx']
    maxx = f['maxx']
    miny = f['miny']
    maxy = f['maxy']
    x.pred.upto(x.succ) {|i|
      if i.between?(minx,maxx)
        y.pred.upto(y.succ) {|j|
          if j.between?(miny,maxy) and i != x || j != y
            nx.replace(i.to_f.to_s)
            ny.replace(j.to_f.to_s)
            yield
          end
        }
      end
    }
  end
end

module External
  extend self, Forwardable

  def_delegators Plant_watering, :function, :assign, :increase, :decrease, :adjacent
end