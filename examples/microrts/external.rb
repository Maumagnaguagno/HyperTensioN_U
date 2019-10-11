module External
  extend self

  def hypot_diff(x1, y1, x2, y2)
    Math.hypot(x1.to_i - x2.to_i, y1.to_i - y2.to_i).to_s
  end

  def adjacent(x1, y1, x2, y2, gx, gy, width, height)
    x1 = x1.to_i
    y1 = y1.to_i
    if x2.empty?
      gx = gx.to_i
      gy = gy.to_i
      width = width.to_i
      height = height.to_i
      list = [
        [x1 - 1, y1 - 1], [x1, y1 - 1], [x1 + 1 , y1 - 1],
        [x1 - 1, y1],                   [x1 + 1, y1],
        [x1 - 1, y1 + 1], [x1, y1 + 1], [x1 + 1, y1 + 1],
      ]
      list.select! {|i,j| 0 <= i and i < width and 0 <= j and j < height}
      list.sort_by! {|i,j| Math.hypot(i - gx, j - gy)}.each {|i,j|
        x2.replace(i.to_f.to_s)
        y2.replace(j.to_f.to_s)
        yield
      }
    else
      x2 = x2.to_i
      y2 = y2.to_i
      (x1 - x2).abs == 1 && y1 == y2 or x1 == x2 && (y1 - y2).abs == 1
    end
  end

  def in_range(x, y, ax, ay, tx, ty, range, width, height)
    ax = ax.to_i
    ay = ay.to_i
    tx = tx.to_i
    ty = ty.to_i
    range = range.to_i
    width = width.to_i - 1
    height = height.to_i - 1
    minx = tx > range ? tx - range : 0
    miny = ty > range ? ty - range : 0
    maxx = tx + range
    maxy = ty + range
    maxx = width if maxx > width
    maxy = height if maxy > height
    list = []
    minx.upto(maxx) {|tox|
      miny.upto(maxy) {|toy|
        list << [tox, toy] if Math.hypot(tx - tox, ty - toy) <= range
      }
    }
    list.sort_by! {|i,j| Math.hypot(ax - i, ay - j)}.each {|i,j|
      x.replace(i.to_f.to_s)
      y.replace(j.to_f.to_s)
      yield
    }
  end
end