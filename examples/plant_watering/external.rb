require 'forwardable'
require_relative '../../../HyperTensioN/examples/experiments/Function'

module Plant_watering
  prepend Function

  def adjacent(x, y, nx, ny, gx, gy)
    x = x.to_f
    y = y.to_f
    f = @state[:function]
    raise 'Position out of bounds' unless x.between?(f['minx'], f['maxx']) and y.between?(f['miny'], f['maxy'])
    gxf = gx.to_f
    gyf = gy.to_f
    if x < gxf then nx.replace((x + 1).to_s)
    elsif x > gxf then nx.replace((x - 1).to_s)
    else nx.replace(gx)
    end
    if y < gyf then ny.replace((y + 1).to_s)
    elsif y > gyf then ny.replace((y - 1).to_s)
    else ny.replace(gy)
    end
    yield
  end
end

module External
  extend self, Forwardable

  def_delegators Plant_watering, :function, :assign, :increase, :decrease, :adjacent
end