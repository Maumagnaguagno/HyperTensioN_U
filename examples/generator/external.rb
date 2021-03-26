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

External = Generator