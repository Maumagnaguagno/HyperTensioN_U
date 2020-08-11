require 'forwardable'
require_relative '../../../HyperTensioN/examples/experiments/Function'

module Car_linear
  prepend Continuous

  # (:process displacement :precondition (engine_running) :effect (increase (d) (* #t (v))) )
  def displacement(t)
    function_interval('v', 0, t.to_i - 1, false)
  end

  # (:process moving :precondition (engine_running) :effect (increase (v) (* #t (a))) )
  def moving(t)
    function_interval('a', 0, t.to_i - 1, false)
  end

  def moving_custom(t)
    f = 'a'
    v = a = ot = 0
    @state[:event].each {|type,g,value,start|
      if f == g and start <= t
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

  def_delegators Car_linear, :function, :process, :event, :event_effect, :process_effect

  def step(t, min = 0.0, max = Float::INFINITY, epsilon = 1.0)
    min.to_f.step(max.to_f, epsilon.to_f) {|i|
      t.replace(i.to_s)
      yield
    }
  end
end