require_relative '../../../HyperTensioN/examples/experiments/Debug'

module External
  include Debug

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

  def shiftl(list)
    list.shift
  end

  def approx(terms)
    External.state[terms.shift].any? {|terms2|
      terms == terms2 or not terms.zip(terms2) {|t1,t2|
        break true unless t1 == t2 or (t1.match?(/^-?\d/) and t2.match?(/^-?\d/) and (diff = ((t1 = t1.to_f) - (t2 = t2.to_f)).abs) <= 0.001 || diff / (t1 > t2 ? t1 : t2).abs <= 0.001)
      }
    }
  end
end