require 'forwardable'
require_relative '../../../HyperTensioN/examples/experiments/Protection'
require_relative '../../../HyperTensioN/examples/experiments/Function'

module Generator
  prepend Protection, Continuous

  def problem(state, *args)
    state[:function] = {
      ['fuellevel', 'gen'] => (1000 - state['available'].size * 20).to_f,
      ['capacity', 'gen'] => 1000.0
    }
    super(state, *args)
  end

  def identity(t)
    t
  end

  def double(t)
    t * 2
  end
end

module External
  extend self
  extend Forwardable

  def_delegators Generator, :protect, :unprotect, :function, :assign, :increase, :decrease, :scale_up, :scale_down, :process, :event

  def time(t, min = 0.0, max = Float::INFINITY, epsilon = 1.0)
    min.to_f.step(max.to_f, epsilon.to_f) {|i|
      t.replace(i.to_s)
      yield
    }
  end
end