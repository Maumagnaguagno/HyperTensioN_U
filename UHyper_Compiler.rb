module UHyper_Compiler
  extend self

  SPACER = '-' * 47

  #-----------------------------------------------
  # Predicates to Hyper
  #-----------------------------------------------

  def predicates_to_hyper(output, predicates, indentation = '      ', yielder = '')
    if predicates.empty?
      output << "\n#{indentation}#{yielder}[]"
    else
      group = predicates.map {|g| g.map {|i| evaluate(i)}.join(', ')}.join("],\n#{indentation}  [")
      output << "\n#{indentation}#{yielder}[\n#{indentation}  [" << group << "]\n#{indentation}]"
    end
  end

  #-----------------------------------------------
  # Expression to Hyper
  #-----------------------------------------------

  def expression_to_hyper(precond_expression, axioms)
    case precond_expression.first
    when 'and', 'or'
      if precond_expression.size == 2 then expression_to_hyper(precond_expression[1], axioms)
      else '(' << precond_expression.drop(1).map! {|exp| expression_to_hyper(exp, axioms)}.join(" #{precond_expression.first} ") << ')'
      end
    when 'not'
      raise "Wrong number of arguments #{precond_expression.join(' ')}, expected 1" if precond_expression.size != 2
      'not ' << expression_to_hyper(precond_expression[1], axioms)
    when 'call' then call(precond_expression)
    else
      # Empty list or nil is false
      if precond_expression.empty?
        'false'
      else
        terms = precond_expression.drop(1).map! {|i| evaluate(i)}.join(', ')
        if axioms.assoc(precond_expression.first) then "#{precond_expression.first}(#{terms})"
        else "@state['#{precond_expression.first}'].include?([#{terms}])"
        end
      end
    end
  end

  #-----------------------------------------------
  # Call
  #-----------------------------------------------

  def call(precond_expression)
    case function = precond_expression[1]
    # Binary math
    when '+', '-', '*', '/', '%', '^'
      raise "Wrong number of arguments for #{precond_expression.join(' ')}, expected 3" if precond_expression.size != 4
      ltoken = evaluate(precond_expression[2])
      rtoken = evaluate(precond_expression[3])
      if ltoken =~ /^('?)(-?\d+(?>\.\d+)?)\1$/ then ltoken = $2.to_f
      else ltoken.sub!(/\.to_s$/,'') or ltoken << '.to_f'
      end
      if rtoken =~ /^('?)(-?\d+(?>\.\d+)?)\1$/ then rtoken = $2.to_f
      else rtoken.sub!(/\.to_s$/,'') or rtoken << '.to_f'
      end
      function = '**' if function == '^'
      if ltoken.instance_of?(Float) and rtoken.instance_of?(Float) then ltoken.send(function, rtoken).to_s
      else "(#{ltoken} #{function} #{rtoken}).to_s"
      end
    # Unary math
    when 'abs', 'sin', 'cos', 'tan'
      raise "Wrong number of arguments for #{precond_expression.join(' ')}, expected 2" if precond_expression.size != 3
      ltoken = evaluate(precond_expression[2])
      if ltoken =~ /^('?)(-?\d+(?>\.\d+)?)\1$/ then function == 'abs' ? $2.sub(/^-/,'') : Math.send(function, $2.to_f).to_s
      elsif function == 'abs' then "#{ltoken}.sub(/^-/,'')"
      else
        ltoken.sub!(/\.to_s$/,'') or ltoken << '.to_f'
        "Math.#{function}(#{ltoken}).to_s"
      end
    # Comparison
    when '=', '!=', '<', '<=', '>=', '>'
      raise "Wrong number of arguments for #{precond_expression.join(' ')}, expected 3" if precond_expression.size != 4
      ltoken = evaluate(precond_expression[2])
      rtoken = evaluate(precond_expression[3])
      if ltoken == rtoken then (function == '=' or function == '<=' or function == '>=').to_s
      else
        ltoken << '.to_s' if ltoken !~ /^[\w']/
        rtoken << '.to_s' if rtoken !~ /^[\w']/
        "(#{ltoken} #{function == '=' ? '==' : function} #{rtoken})"
      end
    else "External.#{function}(#{precond_expression.drop(2).map{|term| evaluate(term)}.join(', ')})"
    end
  end

  #-----------------------------------------------
  # Evaluate
  #-----------------------------------------------

  def evaluate(term)
    case term
    when Array then term.first == 'call' ? call(term) : "[#{term.map {|i| evaluate(i)}.join(', ')}]"
    when String then term.start_with?('?') ? term.sub(/^\?/,'') : "'#{term =~ /^-?\d+$/ ? term.to_f : term}'"
    end
  end

  #-----------------------------------------------
  # Operators to Hyper
  #-----------------------------------------------

  def operator_to_hyper(name, param, precond_expression, effect_add, effect_del, axioms, define_operators)
    define_operators << "\n  def #{name}#{"(#{param.map {|j| j.sub(/^\?/,'')}.join(', ')})" unless param.empty?}\n    "
    if effect_add.empty? and effect_del.empty?
      if precond_expression.empty?
        # Empty
        define_operators << "true\n  end\n"
      else
        # Sensing
        define_operators << "#{expression_to_hyper(precond_expression, axioms)}\n  end\n"
      end
    else
      # Effective if preconditions hold
      define_operators << "return unless #{expression_to_hyper(precond_expression, axioms)}\n    " unless precond_expression.empty?
      # Effective
      predicates_to_hyper(define_operators << "apply(\n      # Add effects", effect_add)
      predicates_to_hyper(define_operators << ",\n      # Del effects", effect_del)
      define_operators << "\n    )\n  end\n"
    end
  end

  #-----------------------------------------------
  # Compile domain
  #-----------------------------------------------

  def compile_domain(domain_name, problem_name, operators, methods, predicates, state, tasks, axioms, reward, hypertension_filename = File.expand_path('../Hypertension_U', __FILE__))
    domain_str = "require_relative 'external' if File.exist?(File.expand_path('../external.rb', __FILE__))\n\nmodule #{domain_name.capitalize}\n  include Hypertension_U\n  extend self\n\n  ##{SPACER}\n  # Domain\n  ##{SPACER}\n\n  @domain = {\n    # Operators"
    # Operators
    define_operators = ''
    operators.each_with_index {|op,i|
      if op.size == 6
        domain_str << "\n    '#{op.first}' => #{op[5]}#{',' if operators.size.pred != i or not methods.empty?}"
        operator_to_hyper(op.first, op[1], op[2], op[3], op[4], axioms, define_operators)
      else
        domain_str << "\n    '#{op.first}' => {"
        opname, param, precond_expression, *effects = op
        until effects.empty?
          operator_to_hyper(opname = effects.shift, param, precond_expression, effects.shift, effects.shift, axioms, define_operators)
          domain_str << "\n      '#{opname}' => #{effects.shift}#{',' unless effects.empty?}"
        end
        domain_str << "\n    }#{',' if operators.size.pred != i or not methods.empty?}"
      end
    }
    # Methods
    define_methods = ''
    domain_str << "\n    # Methods"
    methods.each_with_index {|met,mi|
      domain_str << "\n    '#{met.first}' => [\n"
      variables = met[1].empty? ? '' : "(#{met[1].map {|i| i.sub(/^\?/,'')}.join(', ')})"
      met.drop(2).each_with_index {|dec,i|
        domain_str << "      '#{met.first}_#{dec.first}'#{',' if met.size - 3 != i}\n"
        define_methods << "\n  def #{met.first}_#{dec.first}#{variables}"
        # Ground
        if dec[1].empty?
          # No preconditions
          # TODO modify parser to apply expression_to_hyper directly
          define_methods << "\n    return unless " << expression_to_hyper(['and', *dec[2], *dec[3].map {|pre| ['not', pre]}], axioms) unless dec[2].empty? and dec[3].empty?
          predicates_to_hyper(define_methods, dec[4], '    ', 'yield ')
        # Lifted
        else
          lifted_axioms_calls = []
          ground_axioms_calls = []
          dec[2].reject! {|pre| (pre.flatten.any? {|i| i.start_with?('?') and dec[1].include?(i)} ? lifted_axioms_calls : ground_axioms_calls) << pre if pre.first.start_with?('call') or axioms.assoc(pre.first)}
          dec[3].reject! {|pre| (pre.flatten.any? {|i| i.start_with?('?') and dec[1].include?(i)} ? lifted_axioms_calls : ground_axioms_calls) << ['not', pre] if pre.first.start_with?('call') or axioms.assoc(pre.first)}
          define_methods << "\n    return unless " << expression_to_hyper(ground_axioms_calls.unshift('and'), axioms) unless ground_axioms_calls.empty?
          dec[1].each {|free| define_methods << "\n    #{free.sub(/^\?/,'')} = ''"}
          predicates_to_hyper(define_methods << "\n    generate(\n      # Positive preconditions", dec[2])
          predicates_to_hyper(define_methods << ",\n      # Negative preconditions", dec[3])
          dec[1].each {|free| define_methods << ', ' << free.sub(/^\?/,'')}
          define_methods << "\n    ) {"
          define_methods << "\n      next if " << expression_to_hyper(lifted_axioms_calls.unshift('and'), axioms) unless lifted_axioms_calls.empty?
          predicates_to_hyper(define_methods, dec[4], '      ', 'yield ')
          define_methods << "\n    }"
        end
        define_methods << "\n  end\n"
      }
      domain_str << (methods.size.pred == mi ? '    ]' : '    ],')
    }
    domain_str << "\n  }\n\n"
    # Reward
    unless reward.empty?
      domain_str << "  ##{SPACER}\n  # State valuation\n  ##{SPACER}\n\n  def state_valuation(old_state)\n    value = 0\n"
      reward.each {|pre,value| domain_str << "    value += #{value} if not old_state['#{pre.first}'].include?(#{pre.drop(1)}) and @state['#{pre.first}'].include?(#{pre.drop(1)})\n"}
      domain_str << "    value\n  end\n\n"
    end
    # Axioms
    unless axioms.empty?
      domain_str << "  ##{SPACER}\n  # Axioms\n  ##{SPACER}\n\n"
      axioms.each {|name,param,*expressions|
        domain_str << "  def #{name}(#{param.map {|i| i.sub(/^\?/,'')}.join(', ')})\n"
        expressions.each_slice(2) {|label,exp|
          domain_str << "    # #{label}\n"
          exp = expression_to_hyper(exp, axioms)
          domain_str << (exp == 'false' ? "    # return true if false\n" : "    return true if #{exp}\n")
        }
        domain_str << "  end\n\n"
      }
    end
    # Definitions
    domain_str << "  ##{SPACER}\n  # Operators\n  ##{SPACER}\n#{define_operators}\n  ##{SPACER}\n  # Methods\n  ##{SPACER}\n#{define_methods}end"
    domain_str.gsub!(/\b-\b/,'_')
    hypertension_filename ? "# Generated by Hype\nrequire '#{hypertension_filename}'\n#{domain_str}" : domain_str
  end

  #-----------------------------------------------
  # Compile problem
  #-----------------------------------------------

  def compile_problem(domain_name, problem_name, operators, methods, predicates, state, tasks, axioms, reward, domain_filename = nil)
    problem_str = "# Objects\n"
    # Extract information
    objects = []
    start_hash = {}
    predicates.each_key {|i| start_hash[i] = []}
    state.each {|pre,*terms|
      (start_hash[pre] ||= []) << terms
      objects.concat(terms)
    }
    ordered = tasks.shift
    tasks.each {|pre,*terms| objects.concat(terms)}
    # Objects
    objects.uniq!
    objects.each {|i|
      if i.instance_of?(String)
        problem_str << "#{i} = '#{i}'\n" if i !~ /^-?\d+(?>\.\d+)?$/
      else problem_str << "#{i.join('_').delete('.')} = #{evaluate(i)}\n"
      end
    }
    problem_str << "\n#{domain_name.capitalize}.problem(\n  # Start\n  {\n"
    # Start
    start_hash.each_with_index {|(k,v),i|
      problem_str << "    '#{k}' => ["
      problem_str << "\n      [" << v.map! {|obj| obj.map! {|o| o.instance_of?(String) ? o =~ /^-?\d+(?>\.\d+)?$/ ? "'#{o.to_f}'" : o : o.join('_').delete('.')}.join(', ')}.join("],\n      [") << "]\n    " unless v.empty?
      problem_str << (start_hash.size.pred == i ? ']' : "],\n")
    }
    # Tasks
    group = []
    tasks.each {|t| group << "    ['#{t.first}'#{', ' if t.size > 1}#{t.drop(1).map! {|o| o.instance_of?(String) ? o =~ /^-?\d+(?>\.\d+)?$/ ? "'#{o.to_f}'" : o : o.join('_').delete('.')}.join(', ')}]"}
    problem_str << "\n  },\n  # Tasks\n  [\n" << group .join(",\n") << "\n  ],\n  # Debug\n  ARGV.first == 'debug',\n  # Maximum plans found\n  ARGV[1] ? ARGV[1].to_i : -1,\n  # Minimum probability for plans\n  ARGV[2] ? ARGV[2].to_f : 0"
    tasks.unshift(ordered) unless tasks.empty?
    problem_str.gsub!(/\b-\b/,'_')
    domain_filename ? "# Generated by Hype\nrequire_relative '#{domain_filename}'\n\n#{problem_str}\n)" : "#{problem_str}\n)"
  end
end