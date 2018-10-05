require 'forwardable'
require_relative '../../../HyperTensioN/examples/experiments/Debug'

module External
  extend self, Forwardable

  def_delegators External, :print, :print_state, :breakpoint

  QUEUE = []

  def push(element)
    QUEUE << element
  end

  def shift
    QUEUE.shift
  end

  def size
    QUEUE.size.to_f.to_s
  end

  def approx(terms)
    External.state[terms.shift].any? {|terms2|
      terms == terms2 or terms.zip(terms2).all? {|t1,t2|
        t1 == t2 or (t1 =~ /^-?\d/ and t2 =~ /^-?\d/ and (diff = ((t1 = t1.to_f) - (t2 = t2.to_f)).abs) <= 0.001 || diff / (t1 > t2 ? t1 : t2).abs <= 0.001)
      }
    }
  end
end