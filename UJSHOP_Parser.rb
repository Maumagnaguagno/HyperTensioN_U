module UJSHOP_Parser
  extend self

  attr_reader :domain_name, :problem_name, :operators, :methods, :predicates, :state, :tasks, :axioms, :reward

  AND = 'and'
  OR  = 'or'
  NOT = 'not'
  NIL = 'nil'

  #-----------------------------------------------
  # Scan tokens
  #-----------------------------------------------

  def scan_tokens(filename)
    (str = IO.read(filename)).gsub!(/;.*$/,'')
    str.downcase!
    stack = []
    list = []
    str.scan(/[()]|[^\s()]+/) {|t|
      case t
      when '('
        stack << list
        list = []
      when ')'
        stack.empty? ? raise('Missing open parentheses') : list = stack.pop << list
      else list << t
      end
    }
    raise 'Missing close parentheses' unless stack.empty?
    raise 'Malformed expression' if list.size != 1
    list.first
  end

  #-----------------------------------------------
  # Define effects
  #-----------------------------------------------

  def define_effects(name, group)
    raise "Error with #{name} effects" unless group.instance_of?(Array)
    group.each {|pre| pre.first != NOT ? @predicates[pre.first.freeze] = true : raise('Unexpected not in effects')}
  end

  #-----------------------------------------------
  # Define expression
  #-----------------------------------------------

  def define_expression(name, group)
    # TODO support nil
    raise "Error with #{name}" unless group.instance_of?(Array)
    group.unshift(first = AND) if (first = group.first).instance_of?(Array)
    if first == AND or first == OR
      if group.size == 1
        raise "Unexpected zero arguments for #{first} in #{name}"
      elsif group.size == 2
        define_expression(name, group.replace(group.last))
      else group.drop(1).each {|g| define_expression(name, g)}
      end
    elsif first == NOT
      raise "Unexpected multiple arguments for not in #{name}" if group.size != 2
      define_expression(name, group.last)
    elsif first != 'call' and not @axioms.assoc(first)
      @predicates[first.freeze] ||= false
    end
  end

  #-----------------------------------------------
  # Parse operator
  #-----------------------------------------------

  def parse_operator(op)
    op.shift
    raise 'Action without name definition' unless (name = op.first.shift).instance_of?(String)
    name.sub!(/^!!/,'invisible_') or name.sub!(/^!/,'')
    raise "Action #{name} redefined" if @operators.assoc(name)
    raise "Operator #{name} have size #{op.size} instead of 4 or more" if op.size < 4
    @operators << operator = [name, op.shift, []]
    # Preconditions
    if (group = op.shift) != NIL
      define_expression("#{name} preconditions", operator[2] = group)
    end
    # Effects
    if op.size < 2
      raise "Error with #{name} effects"
    elsif op.size <= 3
      operator[4] = (group = op.shift) != NIL ? define_effects(name, group) : []
      operator[3] = (group = op.shift) != NIL ? define_effects(name, group) : []
      operator << (op.empty? ? 1 : op.shift.to_f)
    else
      i = 0
      until op.empty?
        operator << (op.first.instance_of?(String) ? op.shift : "#{name}_#{i}")
        del = (group = op.shift) != NIL ? define_effects(name, group) : []
        add = (group = op.shift) != NIL ? define_effects(name, group) : []
        operator.push(add, del, op.shift.to_f)
        i += 1
      end
    end
  end

  #-----------------------------------------------
  # Parse method
  #-----------------------------------------------

  def parse_method(met)
    met.shift
    # Method may already have decompositions associated
    name = (group = met.first).shift
    @methods << method = [name, group] unless method = @methods.assoc(name)
    met.shift
    until met.empty?
      # Optional label, add index for the unlabeled decompositions
      if met.first.instance_of?(String)
        label = met.shift
        raise "Method #{name} redefined #{label} decomposition" if method.drop(2).assoc(label)
      else label = "case_#{method.size - 2}"
      end
      method << [label, free_variables = [], pos = [], neg = []]
      # Preconditions
      if (group = met.shift) != NIL
        raise "Error with #{name} preconditions" unless group.instance_of?(Array)
        group.each {|pre|
          pre.first != NOT ? pos << pre : pre.size == 2 ? neg << pre = pre.last : raise("Error with #{name} negative preconditions")
          @predicates[pre.first.freeze] ||= false
          free_variables.concat(pre.select {|i| i.instance_of?(String) and i.start_with?('?') and not method[1].include?(i)})
        }
        free_variables.uniq!
      end
      # Subtasks
      if (group = met.shift) != NIL
        raise "Error with #{name} subtasks" unless group.instance_of?(Array)
        group.each {|pre| pre.first.sub!(/^!!/,'invisible_') or pre.first.sub!(/^!/,'')}
        method.last << group
      else method.last << []
      end
    end
  end

  #-----------------------------------------------
  # Parse axiom
  #-----------------------------------------------

  def parse_axiom(ax)
    ax.shift
    # Variable names are replaced, only arity must match
    if axiom = @axioms.assoc(name = (param = ax.shift).shift)
      raise "Axiom #{name} defined with arity #{axiom[1].size}, unexpected arity #{param.size}" if param.size != axiom[1].size
    else @axioms << axiom = [name, Array.new(param.size) {|i| "?parameter#{i}"}]
    end
    # Expand constant parameters to equality call
    const_param = []
    param.each_with_index {|p,i| const_param << ['call', '=', "?parameter#{i}", p] unless p.start_with?('?')}
    while exp = ax.shift
      if exp.instance_of?(String) and exp != NIL
        label = exp
        raise "Expected axiom definition after label #{label} on #{name}" unless exp = ax.shift
      else label = "case #{axiom.size - 2 >> 1}"
      end
      # Add constant parameters to expression if any
      exp.flatten.each {|value|
        if value.start_with?('?') and i = param.index(value)
          value.replace("?parameter#{i}")
        end
      }
      exp = [AND, *const_param, exp] unless const_param.empty?
      define_expression("axiom #{name}", exp)
      axiom.push(label, exp)
    end
  end

  #-----------------------------------------------
  # Parse domain
  #-----------------------------------------------

  def parse_domain(domain_filename)
    if (tokens = scan_tokens(domain_filename)).instance_of?(Array) and tokens.shift == 'defdomain'
      @operators = []
      @methods = []
      @axioms = []
      @reward = []
      raise 'Found group instead of domain name' if tokens.first.instance_of?(Array)
      @domain_name = tokens.shift
      @predicates = {}
      raise 'More than one group to define domain content' if tokens.size != 1
      tokens = tokens.shift
      while group = tokens.shift
        case group.first
        when ':operator' then parse_operator(group)
        when ':method' then parse_method(group)
        when ':-' then parse_axiom(group)
        when ':reward' then (@reward = group).shift
        else raise "#{group.first} is not recognized in domain"
        end
      end
    else raise "File #{domain_filename} does not match domain pattern"
    end
  end

  #-----------------------------------------------
  # Parse problem
  #-----------------------------------------------

  def parse_problem(problem_filename)
    if (tokens = scan_tokens(problem_filename)).instance_of?(Array) and tokens.size.between?(5,6) and tokens.shift == 'defproblem'
      @problem_name = tokens.shift
      raise 'Different domain specified in problem file' if @domain_name != tokens.shift
      @state = tokens.first != NIL ? tokens.shift : []
      if tokens.first != NIL
        @tasks = tokens.shift
        # Tasks may be ordered or unordered
        @tasks.shift unless order = (@tasks.first != ':unordered')
        @tasks.each {|pre| pre.first.sub!(/^!!/,'invisible_') or pre.first.sub!(/^!/,'')}
        @tasks.unshift(order)
      else @tasks = []
      end
    else raise "File #{problem_filename} does not match problem pattern"
    end
  end
end