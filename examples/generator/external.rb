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

  def protect(pos, neg)
    Generator.protect(pos, neg)
  end

  def unprotect(pos, neg)
    Generator.unprotect(pos, neg)
  end

  def function(f)
    Generator.function(f)
  end

  def assign(f, value)
    Generator.assign(f, value)
  end

  def increase(f, value)
    Generator.increase(f, value)
  end

  def decrease(f, value)
    Generator.decrease(f, value)
  end

  def scale_up(f, value)
    Generator.scale_up(f, value)
  end

  def scale_down(f, value)
    Generator.scale_down(f, value)
  end

  def time(t, min = 0, max = Float::INFINITY, epsilon = 1)
    min.step(max, epsilon) {|i|
      t.replace(i.to_s)
      yield
    }
  end
end