require 'forwardable'
require_relative '../../../Hypertension/examples/experiments/Protection'
require_relative '../../../Hypertension/examples/experiments/Function'

module Generator
  prepend Protection
  include Function

  def problem(state, *args)
    state[:function] = {
      ['fuellevel', 'gen'] => 1000 - state['available'].size * 20,
      ['capacity', 'gen'] => 1000
    }
    super(state, *args)
  end
end

module External
  extend self
  extend Forwardable

  def_delegators Generator, :protect, :unprotect, :function, :assign, :increase, :decrease, :scale_up, :scale_down

  def time(t, min = 0, max = Float::INFINITY, epsilon = 1)
    min.step(max, epsilon) {|i|
      t.replace(i.to_s)
      yield
    }
  end
end