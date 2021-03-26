require 'forwardable'
require_relative '../../../HyperTensioN/examples/experiments/Function'
require_relative '../../../HyperTensioN/examples/experiments/Debug'
require_relative '../../../Polygonoid/examples/search/Search'
require_relative '../../../Polygonoid/examples/circular/Circular'

module Turtlebot
  prepend Continuous, Debug

  ROBOT = 'turtle'
  X = ['x', ROBOT]
  Y = ['y', ROBOT]
  A  = ['a', ROBOT]
  AX = ['ax', ROBOT]
  VX = ['vx', ROBOT]

  def current_angle
    @state[:event].reverse_each {|type,f,value,start| return value if f == A}
    @state[:function][A]
  end

  # (:process displacement_xy :precondition (engine_running) :effect (increase (xy robot) (* (cossin angle) (* #t (v)))) )
  def displacement_x(t)
    Math.cos(current_angle) * function_interval(VX, 0, t - 1, false)
  end

  def displacement_y(t)
    Math.sin(current_angle) * function_interval(VX, 0, t - 1, false)
  end

  # (:process moving :precondition (engine_running) :effect (increase (v) (* #t (a))) )
  def moving(t)
    @state[:function][VX] + function_interval(AX, 0, t - 1, false)
  end

  def moving_custom(t)
    v = @state[:function][VX]
    a = @state[:function][AX]
    ot = 0
    @state[:event].each {|type,f,value,start|
      if f == AX and start <= t
        v += a * (start - ot)
        ot = start
        case type
        when 'increase' then a += value
        when 'decrease' then a -= value
        end
      end
    }
    v + a * (t - ot)
  end
end

module External
  extend self, Forwardable

  CLOCK = 'clock'
  COUNTER = 'counter'
  RAD2DEG = 180 / Math::PI
  PI2 = Math::PI * 2
  CIRCLES = [
    Circle.new( 0.5, 28.5, 3.5),
    Circle.new(46.5, 28.5, 3.5),
    Circle.new(24.0,  0.5, 3.0),
    Circle.new(24.0, 58.5, 3.0),
    Circle.new(24.5, 53.0, 8.5),
    Circle.new(24.5, 20.5, 3.0),
    Circle.new(40.5,  5.5, 7.0)
  ]

  def_delegators Turtlebot, :function, :process, :event, :event_effect, :process_effect, :step

  @symbol_object = {}
  @pos_counter = 0

  def symbol(object)
    symbol = @symbol_object.key(object) or @symbol_object[symbol = "pos#{@pos_counter += 1}"] = object
    symbol
  end

  def closest(circle, to, out_circle, in_dir, out_dir, goal)
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

  def position(x, y)
    symbol(Circle.new(x.to_f, y.to_f, 0))
  end

  def radians_to_degree_difference(start, finish)
    (finish.to_f - start.to_f) * RAD2DEG % 360
  end

  def distance(x, y, dx, dy)
    Math.hypot(x.to_f - dx.to_f, y.to_f - dy.to_f).to_s
  end

  # https://stackoverflow.com/questions/21483999/using-atan2-to-find-angle-between-two-vectors
  def atan(x1, y1, x2, y2)
    angle = Math.atan2(y2.to_f - y1.to_f, x2.to_f - x1.to_f)
    (angle < 0 ? angle + PI2 : angle).to_s
  end

  def x(position)
    @symbol_object[position].x.to_f.to_s
  end

  def y(position)
    @symbol_object[position].y.to_f.to_s
  end
end

#-----------------------------------------------
# Main
#-----------------------------------------------
if $0 == __FILE__
  require 'test/unit'

  class Spin < Test::Unit::TestCase

    SAME = nil

    def turn(start, finish)
      diff = (finish - start) % 360
      diff == 0 ? SAME : diff > 180 ? CLOCK : COUNTER
    end

    def test_turn
      assert_same(SAME, turn(0, 0))
      assert_same(SAME, turn(0, 360))
      assert_same(SAME, turn(360, 0))
      assert_same(SAME, turn(360, 360))
      assert_same(CLOCK,   turn(90, 0))
      assert_same(COUNTER, turn(90, 180))
      assert_same(COUNTER, turn(270, 0))
      assert_same(CLOCK,   turn(270, 180))
      assert_same(COUNTER, turn(359, 1))
      assert_same(CLOCK,   turn(359, 357))
      assert_same(COUNTER, turn(1,3))
      assert_same(CLOCK,   turn(1,359))
      assert_same(COUNTER, turn(0, 45))
      assert_same(CLOCK,   turn(45, 0))
    end
  end
end