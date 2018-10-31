require 'forwardable'
require_relative '../../../HyperTensioN/examples/experiments/Function'

module Generator
  prepend Continuous

  def identity(t)
    t
  end

  def double(t)
    t * 2
  end
end

module External
  extend self, Forwardable

  def_delegators Generator, :function, :process

  def step(t, min = 0.0, max = Float::INFINITY, epsilon = 1.0)
    min.to_f.step(max.to_f, epsilon.to_f) {|i|
      t.replace(i.to_s)
      yield
    }
  end
end