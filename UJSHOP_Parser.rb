module UJSHOP_Parser
  extend self

  attr_reader :domain_name, :problem_name, :operators, :methods, :predicates, :state, :tasks, :axioms, :rewards, :attachments

  AND = 'and'
  OR  = 'or'
  NOT = 'not'

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
      when 'nil' then list << []
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
    raise "Error with #{name}" unless group.instance_of?(Array)
    # Add implicit conjunction to expression
    group.unshift(first = AND) if (first = group.first).instance_of?(Array)
    return unless first
    if first == AND or first == OR
      if group.size > 2 then group.drop(1).each {|g| define_expression(name, g)}
      elsif group.size == 2 then define_expression(name, group.replace(group.last))
      else raise "Unexpected zero arguments for #{first} in #{name}"
      end
    elsif first == NOT
      raise "Unexpected multiple arguments for not in #{name}" if group.size != 2
      define_expression(name, group.last)
    elsif first == 'call'
      raise "Unexpected list as function name in #{name}" if group[1].instance_of?(Array)
    elsif a = @axioms.assoc(first)
      raise "Axiom #{first} defined with arity #{a[1].size}, unexpected arity #{group.size.pred}" if a[1].size != group.size.pred
    elsif a = @attachments.assoc(first)
      raise "Attachment #{first} defined with arity #{a.size.pred}, unexpected arity #{group.size.pred}" if a.size != group.size
    else @predicates[first.freeze] ||= false
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
    define_expression("#{name} preconditions", operator[2] = op.shift)
    # Effects
    if op.size < 2
      raise "Error with #{name} effects"
    elsif op.size <= 3
      define_effects(name, operator[4] = op.shift)
      define_effects(name, operator[3] = op.shift)
      operator << (op.empty? ? 1 : op.shift.to_f)
    else
      i = 0
      until op.empty?
        operator << (op.first.instance_of?(String) ? op.shift : "#{name}_#{i}")
        define_effects(name, del = op.shift)
        define_effects(name, add = op.shift)
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
      # Preconditions
      define_expression("#{name} preconditions", precond = met.shift)
      # Subtasks
      raise "Error with #{name} subtasks" unless (group = met.shift).instance_of?(Array)
      method << [label, precond, group.each {|pre| pre.first.sub!(/^!!/,'invisible_') or pre.first.sub!(/^!/,'')}]
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
      if exp.instance_of?(String)
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
    if (tokens = scan_tokens(domain_filename)).instance_of?(Array) and tokens.size == 3 and tokens.shift == 'defdomain'
      raise 'Found group instead of domain name' if tokens.first.instance_of?(Array)
      @domain_name = tokens.shift
      @operators = []
      @methods = []
      @predicates = {}
      @axioms = []
      @rewards = []
      @attachments = []
      tokens = tokens.shift
      while group = tokens.shift
        case group.first
        when ':operator' then parse_operator(group)
        when ':method' then parse_method(group)
        when ':-' then parse_axiom(group)
        when ':rewards' then (@rewards = group).shift
        when ':attachments' then (@attachments = group).shift
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
    if (tokens = scan_tokens(problem_filename)).instance_of?(Array) and tokens.size == 5 and tokens.shift == 'defproblem'
      @problem_name = tokens.shift
      raise 'Different domain specified in problem file' if @domain_name != tokens.shift
      @state = tokens.shift
      @tasks = tokens.shift
      # Tasks may be ordered or unordered
      @tasks.shift unless ordered = (@tasks.first != ':unordered')
      @tasks.each {|pre| pre.first.sub!(/^!!/,'invisible_') or pre.first.sub!(/^!/,'')}.unshift(ordered)
    else raise "File #{problem_filename} does not match problem pattern"
    end
  end
end