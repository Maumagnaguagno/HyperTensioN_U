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

External = Car_linear