module External
  extend self

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

  def breakpoint
    STDIN.gets if @debug
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