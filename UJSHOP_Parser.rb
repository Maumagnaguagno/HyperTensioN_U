require_relative '../HyperTensioN/parsers/JSHOP_Parser'

module UJSHOP_Parser
  include JSHOP_Parser
  extend self

  attr_reader :axioms, :rewards, :attachments

  AND = 'and'
  OR  = 'or'

  #-----------------------------------------------
  # Define expression
  #-----------------------------------------------

  def define_expression(name, group)
    raise "Error with #{name}" unless group.instance_of?(Array)
    return unless first = group.first
    # Add implicit conjunction to expression
    group.unshift(first = AND) if first.instance_of?(Array)
    if first == AND or first == OR
      if group.size > 2 then group.drop(1).each {|g| define_expression(name, g)}
      elsif group.size == 2 then define_expression(name, group.replace(group.last))
      else raise "Unexpected zero arguments for #{first} in #{name}"
      end
    elsif first == NOT
      raise "Expected single argument for not in #{name}" if group.size != 2
      define_expression(name, group.last)
    elsif first == 'call'
      raise "Unexpected list as function name in #{name}" if group[1].instance_of?(Array)
      group.drop(2).each {|g| define_expression(name, g) if g.instance_of?(Array) and g.first == first}
    elsif first == 'assign'
      raise "Expected 2 arguments for assign in #{name}" if group.size != 3
      raise "Unexpected #{group[1]} as variable to assign in #{name}" unless group[1].start_with?('?')
      define_expression(name, group.last) if group.last.instance_of?(Array) and group.last.first == 'call'
    elsif a = @axioms.assoc(first)
      raise "Axiom #{first} defined with arity #{a[1].size}, unexpected arity #{group.size.pred} in #{name}" if a[1].size != group.size.pred
    elsif a = @attachments.assoc(first)
      raise "Attachment #{first} defined with arity up to #{a.size.pred}, unexpected arity #{group.size.pred} in #{name}" if a.size < group.size
    else @predicates[first.freeze] ||= false
    end
  end

  #-----------------------------------------------
  # Define effects
  #-----------------------------------------------

  def define_effects(name, group)
    raise "Error with #{name} effect" unless group.instance_of?(Array)
    group.each {|pre,| pre != NOT ? @predicates[pre.freeze] = true : raise("Unexpected not in #{name} effect") if pre != 'call'}
  end

  #-----------------------------------------------
  # Parse operator
  #-----------------------------------------------

  def parse_operator(op)
    op.shift
    raise 'Operator without name definition' unless (name = op.first.shift).instance_of?(String)
    name.sub!(/^!!/,'invisible_') or name.delete_prefix!('!')
    raise "#{name} redefined" if @operators.assoc(name)
    raise "#{name} have size #{op.size} instead of 4 or more" if op.size < 4
    @operators << operator = [name, op.shift, op.shift]
    # Preconditions
    define_expression("#{name} precondition", operator[2])
    # Effects
    if op.size <= 3
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
    if method = @methods.assoc(name = (group = met.shift).shift)
      raise "Expected same parameters for method #{name}" if method[1] != group
    else @methods << method = [name, group]
    end
    until met.empty?
      # Optional label, add index for the unlabeled decompositions
      if met.first.instance_of?(String)
        label = met.shift
        raise "#{name} redefined #{label} decomposition" if method.drop(2).assoc(label)
      else label = "case_#{method.size - 2}"
      end
      # Preconditions
      define_expression("#{name} precondition", precond = met.shift)
      # Subtasks
      raise "Error with #{name} subtasks" unless (group = met.shift).instance_of?(Array)
      method << [label, precond, group.each {|pre,| pre.sub!(/^!!/,'invisible_') or pre.delete_prefix!('!')}]
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
    param.zip(axiom[1]) {|p,pi| const_param << ['call', '=', pi, p] unless p.start_with?('?')}
    while exp = ax.shift
      if exp.instance_of?(String)
        label = exp
        raise "Expected axiom definition after label #{label} in #{name}" unless exp = ax.shift
      else label = "case #{axiom.size - 2 >> 1}"
      end
      # Add constant parameters to expression if any
      exp.flatten.each {|value|
        if value.start_with?('?') and i = param.index(value)
          value.replace(axiom[1][i])
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
end