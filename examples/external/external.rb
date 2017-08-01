module External
  extend self

  @objects = ['a', 'b', 'c']

  def empty
    @objects.empty?
  end

  def get_next_element
    @objects.shift
  end

  def approx(terms)
    External.state[terms.shift].any? {|terms2|
      terms == terms2 or terms.zip(terms2).all? {|t1,t2|
        t1 == t2 or (t1 =~ /^-?\d/ and t2 =~ /^-?\d/ and (diff = ((t1 = t1.to_f) - (t2 = t2.to_f)).abs) <= 0.001 || diff / (t1 > t2 ? t1 : t2).abs <= 0.001)
      }
    }
  end
end