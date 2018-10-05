require 'forwardable'
require_relative '../../../HyperTensioN/examples/experiments/Protection'
require_relative '../../../HyperTensioN/examples/experiments/Function'

module Car_linear
  prepend Protection, Continuous

  def problem(state, *args)
    function = state[:function] = {}
    state['initial'].each {|f,v| function[f] = v.to_f}
    super(state, *args)
  end

  # (:process displacement :precondition (engine_running) :effect (increase (d) (* #t (v))) )
  def displacement(t)
    d = function('d').to_f
    1.upto(t) {|i| d += External.function('v', i).to_f}
    d
  end

  # (:process moving :precondition (engine_running) :effect (increase (v) (* #t (a))) )
  def moving(t)
    v = function('v').to_f
    a = function('a').to_f
    ot = 0
    @state[:event].each {|type, g, value, start|
      if g == 'a' and start <= t
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

  def_delegators Car_linear, :protect, :unprotect, :function, :assign, :increase, :decrease, :scale_up, :scale_down, :process, :event

  def step(t, min = 0.0, max = Float::INFINITY, epsilon = 1.0)
    min.to_f.step(max.to_f, epsilon.to_f) {|i|
      t.replace(i.to_s)
      yield
    }
  end

  def breakpoint
    STDIN.gets
    true
  end

  def print(*argv)
    puts argv.join(' ')
    true
  end

  def print_state
    puts 'State'.center(20,'-')
    External.state.each {|k,v| v.each {|i| puts "(#{k} #{i.join(' ')})"}}
  end
end