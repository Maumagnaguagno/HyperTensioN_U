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
      output << "\n#{indentation}#{yielder}[\n#{indentation}  [" << predicates.map {|g| g.map {|i| evaluate(i, true)}.join(', ')}.join("],\n#{indentation}  [") << "]\n#{indentation}]"
    end
  end

  #-----------------------------------------------
  # Expression to Hyper
  #-----------------------------------------------

  def expression_to_hyper(precond_expression, axioms, state = '@state')
    case precond_expression.first
    when 'and', 'or'
      if precond_expression.size == 2 then expression_to_hyper(precond_expression[1], axioms, state)
      else '(' << precond_expression.drop(1).map! {|exp| expression_to_hyper(exp, axioms, state)}.join(" #{precond_expression.first} ") << ')'
      end
    when 'not' then 'not ' << expression_to_hyper(precond_expression[1], axioms, state)
    when 'call' then call(precond_expression)
    when 'assign' then '(' << precond_expression[1].delete('?') << ' = ' << evaluate(precond_expression[2], true) << ')'
    else
      # Empty list is false
      if precond_expression.empty? then 'false'
      else
        terms = precond_expression.drop(1).map! {|i| evaluate(i, true)}.join(', ')
        if axioms.assoc(precond_expression.first) then "#{precond_expression.first}(#{terms})"
        else "#{state}['#{precond_expression.first}'].include?([#{terms}])"
        end
      end
    end
  end

  #-----------------------------------------------
  # Call
  #-----------------------------------------------

  def call(expression)
    case function = expression[1]
    # Binary math
    when '+', '-', '*', '/', '%', '^'
      raise "Wrong number of arguments for (#{expression.join(' ')}), expected 3" if expression.size != 4
      ltoken = evaluate(expression[2])
      rtoken = evaluate(expression[3])
      if ltoken =~ /^-?\d/ then ltoken = ltoken.to_f
      else ltoken.chomp!('.to_s') or ltoken << '.to_f'
      end
      if rtoken =~ /^-?\d/ then rtoken = rtoken.to_f
      else rtoken.chomp!('.to_s') or rtoken << '.to_f'
      end
      function = '**' if function == '^'
      if ltoken.instance_of?(Float) and rtoken.instance_of?(Float) then ltoken.send(function, rtoken).to_s
      else "(#{ltoken} #{function} #{rtoken}).to_s"
      end
    # Unary math
    when 'abs', 'sin', 'cos', 'tan'
      raise "Wrong number of arguments for (#{expression.join(' ')}), expected 2" if expression.size != 3
      ltoken = evaluate(expression[2])
      if ltoken =~ /^-?\d/ then function == 'abs' ? ltoken.delete('-') : Math.send(function, ltoken.to_f).to_s
      elsif function == 'abs' then ltoken.sub!(/\.to_s$/,'.abs.to_s') or ltoken << ".delete('-')"
      else "Math.#{function}(#{ltoken.chomp!('.to_s') or ltoken << '.to_f'}).to_s"
      end
    # Comparison
    when '=', '!=', '<', '>', '<=', '>='
      raise "Wrong number of arguments for (#{expression.join(' ')}), expected 3" if expression.size != 4
      ltoken = evaluate(expression[2])
      rtoken = evaluate(expression[3])
      if ltoken == rtoken then (function == '=' or function == '<=' or function == '>=').to_s
      else
        function = '==' if function == '='
        if ltoken =~ /^-?\d/
          ltoken = ltoken.to_f
          return ltoken.send(function, rtoken.to_f).to_s if rtoken =~ /^-?\d/
          rtoken.chomp!('.to_s') or rtoken << '.to_f'
        elsif rtoken =~ /^-?\d/
          rtoken = rtoken.to_f
          ltoken.chomp!('.to_s') or ltoken << '.to_f'
        elsif function != '==' and function != '!='
          ltoken.chomp!('.to_s') or ltoken << '.to_f'
          rtoken.chomp!('.to_s') or rtoken << '.to_f'
        end
        "(#{ltoken} #{function} #{rtoken})"
      end
    # List
    when 'member'
      raise "Wrong number of arguments for (#{expression.join(' ')}), expected 3" if expression.size != 4
      ltoken = evaluate(expression[2], true)
      rtoken = evaluate(expression[3], true)
      "#{rtoken}.include?(#{ltoken})"
    # External
    else "External.#{function}(#{expression.drop(2).map! {|term| evaluate(term, true)}.join(', ')})"
    end
  end

  #-----------------------------------------------
  # Evaluate
  #-----------------------------------------------

  def evaluate(term, quotes = false)
    case term
    when Array
      if term.first == 'call'
        term = call(term)
        quotes ? evaluate(term, true) : term
      else "[#{term.map {|i| evaluate(i, quotes)}.join(', ')}]"
      end
    when String
      if term.start_with?('?') then term.delete('?')
      elsif term =~ /^[a-z]/ then "'#{term}'"
      elsif term =~ /^-?\d/ then quotes ? "'#{term.to_f}'" : term.to_f.to_s
      else term
      end
    end
  end

  #-----------------------------------------------
  # Operator to Hyper
  #-----------------------------------------------

  def operator_to_hyper(name, param, precond_expression, effect_add, effect_del, axioms, define_operators)
    define_operators << "\n  def #{name}#{"(#{param.join(', ').delete!('?')})" unless param.empty?}"
    if effect_add.empty? and effect_del.empty?
      # Empty or sensing
      define_operators << (precond_expression.empty? ? "\n    true\n  end\n" : "\n    #{expression_to_hyper(precond_expression, axioms)}\n  end\n")
    else
      # Effective if preconditions hold
      define_operators << "\n    return unless #{expression_to_hyper(precond_expression, axioms)}" unless precond_expression.empty?
      # Effective
      effect_calls = []
      effect_add.reject! {|pre| effect_calls << call(pre) if pre.first == 'call'}
      unless effect_add.empty? and effect_del.empty?
        predicates_to_hyper(define_operators << "\n    apply(\n      # Add effects", effect_add)
        predicates_to_hyper(define_operators << ",\n      # Del effects", effect_del)
        define_operators << "\n    )"
      end
      define_operators << "\n    " << effect_calls.join(' and ') unless effect_calls.empty?
      define_operators << "\n  end\n"
    end
  end

  #-----------------------------------------------
  # Compile domain
  #-----------------------------------------------

  def compile_domain(domain_name, problem_name, operators, methods, predicates, state, tasks, axioms, rewards, attachments, hypertension_filename = File.expand_path('../Hypertension_U', __FILE__))
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
      variables = met[1].empty? ? '' : "(#{met[1].join(', ').delete!('?')})"
      met.drop(2).each_with_index {|dec,i|
        domain_str << "      '#{met.first}_#{dec.first}'#{',' if met.size - 3 != i}\n"
        define_methods << "\n  def #{met.first}_#{dec.first}#{variables}"
        # Obtain free variables
        # TODO refactor this block to work with complex expressions
        free_variables = []
        precond_attachments = []
        unless (precond_expression = dec[1]).empty?
          precond_expression = precond_expression.first == 'and' ? precond_expression.drop(1) : [precond_expression]
          precond_expression.reject! {|pre|
            if attachments.assoc(pre.first)
              precond_attachments << pre
            elsif pre.first != 'not' and pre.first != 'call' and pre.first != 'assign' and not axioms.assoc(pre.first)
              free_variables.concat(pre.select {|j| j.instance_of?(String) and j.start_with?('?') and not met[1].include?(j)})
              false
            end
          }
        end
        free_variables.uniq!
        ground_free_variables = met[1] + free_variables
        # Filter elements from precondition
        precond_pos = []
        precond_not = []
        lifted_axioms_calls = []
        ground_axioms_calls = []
        dependent_attachments = []
        precond_expression.each {|pre|
          if pre.first != 'not' and pre.first != 'assign'
            pre_flat = pre.flatten
            call_axiom = pre_flat.first == 'call' || axioms.assoc(pre_flat.first)
            if call_axiom and pre_flat.all? {|t| t.instance_of?(String) and not t.start_with?('?') or met[1].include?(t)}
              ground_axioms_calls << pre
            elsif pre_flat.any? {|t| t.instance_of?(String) and t.start_with?('?') and not ground_free_variables.include?(t)}
              dependent_attachments << pre
            elsif call_axiom then lifted_axioms_calls << pre
            else precond_pos << pre
            end
          else
            pre_flat = pre.last.instance_of?(String) ? [pre.last] : pre.last.flatten
            call_axiom = pre_flat.first == 'call'|| pre.first == 'assign' || axioms.assoc(pre_flat.first)
            if call_axiom and pre_flat.all? {|t| t.instance_of?(String) and not t.start_with?('?') or met[1].include?(t)}
              ground_axioms_calls << pre
            elsif pre_flat.any? {|t| t.instance_of?(String) and t.start_with?('?') and not ground_free_variables.include?(t)}
              dependent_attachments << pre
            elsif call_axiom then lifted_axioms_calls << pre
            else precond_not << pre.last
            end
          end
        }
        if free_variables.empty?
          # Ground predicates, axioms and calls
          precond_expression = precond_pos.concat(precond_not.map {|j| ['not', j]}).concat(ground_axioms_calls)
          define_methods << "\n    return unless " << expression_to_hyper(precond_expression.unshift('and'), axioms) unless precond_expression.empty?
          level = 2
        else
          # Ground axioms and calls
          define_methods << "\n    return unless " << expression_to_hyper(ground_axioms_calls.unshift('and'), axioms) unless ground_axioms_calls.empty?
          # Unify free variables
          free_variables.each {|free| define_methods << "\n    #{free.delete('?')} = ''"}
          predicates_to_hyper(define_methods << "\n    generate(\n      # Positive preconditions", precond_pos)
          predicates_to_hyper(define_methods << ",\n      # Negative preconditions", precond_not)
          free_variables.each {|free| define_methods << ', ' << free.delete('?')}
          define_methods << "\n    ) {"
          define_methods << "\n      next unless " << expression_to_hyper(lifted_axioms_calls.unshift('and'), axioms) unless lifted_axioms_calls.empty?
          level = 3
        end
        # Semantic attachments
        precond_attachments.each {|pre,*terms|
          indentation = '  ' * level
          terms.each {|t|
            if t.start_with?('?') and not met[1].include?(t) || free_variables.include?(t)
              free_variables << t
              define_methods << "\n#{indentation}#{t.delete('?')} = ''"
            end
          }
          define_methods << "\n#{indentation}External.#{pre}(#{terms.map! {|t| evaluate(t, true)}.join(', ')}) {"
          level += 1
        }
        unless dependent_attachments.empty?
          raise "Call with free variables in #{met.first} #{dec.first}" if level == 2
          define_methods << "\n#{'  ' * level}next unless " << expression_to_hyper(dependent_attachments.unshift('and'), axioms)
        end
        # Subtasks
        predicates_to_hyper(define_methods, dec[2], '  ' * level, 'yield ')
        level.pred.downto(2) {|l| define_methods << "\n#{'  ' * l}}"}
        define_methods << "\n  end\n"
      }
      domain_str << (methods.size.pred == mi ? '    ]' : '    ],')
    }
    domain_str << "\n  }\n\n"
    # Rewards
    unless rewards.empty?
      domain_str << "  ##{SPACER}\n  # State valuation\n  ##{SPACER}\n\n  def state_valuation(old_state)\n    value = 0\n"
      rewards.each {|trigger,pre,value|
        case trigger
        when 'achieve' then domain_str << "    value += #{value} if not #{expression_to_hyper(pre, axioms, 'old_state')} and #{expression_to_hyper(pre, axioms)}\n"
        when 'maintain' then domain_str << "    value += #{value} if #{expression_to_hyper(pre, axioms, 'old_state')} and #{expression_to_hyper(pre, axioms)}\n"
        end
      }
      domain_str << "    value\n  end\n\n"
    end
    # Axioms
    unless axioms.empty?
      domain_str << "  ##{SPACER}\n  # Axioms\n  ##{SPACER}\n\n"
      axioms.each {|name,param,*expressions|
        domain_str << "  def #{name}(#{param.join(', ').delete!('?')})\n"
        expressions.each_slice(2) {|label,exp|
          exp = expression_to_hyper(exp, axioms)
          domain_str << (exp == 'false' ? "    # #{label} is always false\n" : "    # #{label}\n    return true if #{exp}\n")
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

  def compile_problem(domain_name, problem_name, operators, methods, predicates, state, tasks, axioms, rewards, attachments, domain_filename = nil)
    from = '-+*/%^<>=.'
    to = 'samdrplgef'
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
        problem_str << "#{i} = '#{i}'\n" if i !~ /^-?\d/
      else problem_str << "#{i.join('_').tr(from,to)} = #{evaluate(i, true)}\n"
      end
    }
    problem_str << "\n#{domain_name.capitalize}.problem(\n  # Start\n  {\n"
    # Start
    start_hash.each_with_index {|(k,v),i|
      problem_str << "    '#{k}' => ["
      problem_str << "\n      [" << v.map! {|obj| obj.map! {|o| o.instance_of?(String) ? o =~ /^-?\d/ ? "'#{o.to_f}'" : o : o.join('_').tr(from,to)}.join(', ')}.join("],\n      [") << "]\n    " unless v.empty?
      problem_str << (start_hash.size.pred == i ? ']' : "],\n")
    }
    # Tasks
    problem_str << "\n  },\n  # Tasks\n  [" <<
      tasks.map {|t| "\n    ['#{t.first}'#{', ' if t.size > 1}#{t.drop(1).map! {|o| o.instance_of?(String) ? o =~ /^-?\d/ ? "'#{o.to_f}'" : o : o.join('_').tr(from,to)}.join(', ')}]"}.join(',') <<
      "\n  ],\n  # Debug\n  ARGV.first == 'debug',\n  # Maximum plans found\n  ARGV[1] ? ARGV[1].to_i : -1,\n  # Minimum probability for plans\n  ARGV[2] ? ARGV[2].to_f : 0"
    tasks.unshift(ordered) unless tasks.empty?
    problem_str.gsub!(/\b-\b/,'_')
    domain_filename ? "# Generated by Hype\nrequire_relative '#{domain_filename}'\n\n#{problem_str}\n)" : "#{problem_str}\n)"
  end
end