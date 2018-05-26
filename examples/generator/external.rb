require_relative '../../../Hypertension/examples/experiments/Protection'

module Generator
  prepend Protection

  def problem(state, *args)
    state['function'] = {
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
    Generator.state['function'][f]
  end

  def assign(f, value)
    Generator.state['function'][f] = value.to_f
    axioms_protected?
  end

  def increase(f, value)
    Generator.state['function'][f] += value.to_f
    axioms_protected?
  end

  def decrease(f, value)
    Generator.state['function'][f] -= value.to_f
    axioms_protected?
  end

  def scale_up(f, value)
    Generator.state['function'][f] *= value.to_f
    axioms_protected?
  end

  def scale_down(f, value)
    Generator.state['function'][f] /= value.to_f
    axioms_protected?
  end

  def axioms_protected?
    Generator.state['protect_axiom'].all? {|i| Generator.send(*i)}
  end

  def time(t, min = 0, max = Float::INFINITY, epsilon = 1)
    min.step(max, epsilon) {|i|
      t.replace(i.to_s)
      yield
    }
  end
end