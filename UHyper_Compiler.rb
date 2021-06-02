module UHyper_Compiler
  extend self

  SPACER = '-' * 47

  #-----------------------------------------------
  # Expression to Hyper
  #-----------------------------------------------

  def expression_to_hyper(precond_expression, axioms)
    case precond_expression.first
    when 'and', 'or'
      if precond_expression.size == 2 then expression_to_hyper(precond_expression[1], axioms)
      else '(' << precond_expression.drop(1).map! {|exp| expression_to_hyper(exp, axioms)}.join(" #{precond_expression.first} ") << ')'
      end
    when 'not' then (term = expression_to_hyper(precond_expression[1], axioms)).delete_prefix!('not ') or 'not ' << term
    when 'call' then call(precond_expression)
    when 'assign' then '(' << precond_expression[1].delete('?') << ' = ' << evaluate(precond_expression[2], true) << ')'
    else
      # Empty list is false
      if precond_expression.empty? then 'false'
      else
        terms = precond_expression.drop(1).map! {|i| evaluate(i, true)}.join(', ')
        if axioms.assoc(precond_expression.first) then "#{precond_expression.first}(#{terms})"
        else "@state[#{evaluate(precond_expression.first, true)}].include?([#{terms}])"
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
        quotes && term =~ /^-?\d/ ? "'#{term}'" : term
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
  # Applicable
  #-----------------------------------------------

  def applicable(output, pre, terms, predicates)
    output << "@state[#{evaluate(pre, true)}].include?([#{terms.map! {|t| evaluate(t, true)}.join(', ')}])"
  end

  #-----------------------------------------------
  # Apply
  #-----------------------------------------------

  def apply(modifier, effects, define_operators, duplicated)
    effects.each {|pre,*terms|
      pre_evaluated = evaluate(pre, true)
      if duplicated.include?(pre)
        define_operators << "\n    @state[#{pre_evaluated}]"
      else
        define_operators << "\n    (@state[#{pre_evaluated}] = @state[#{pre_evaluated}].dup)"
        duplicated[pre] = nil
      end
      define_operators << ".#{modifier}([#{terms.map! {|i| evaluate(i, true)}.join(', ')}])"
    }
  end

  #-----------------------------------------------
  # Subtasks to Hyper
  #-----------------------------------------------

  def subtasks_to_hyper(tasks, indentation)
    if tasks.empty? then "#{indentation}yield []"
    else "#{indentation}yield [#{indentation}  [" << tasks.map {|g| g.map {|i| evaluate(i, true)}.join(', ')}.join("],#{indentation}  [") << "]#{indentation}]"
    end
  end

  #-----------------------------------------------
  # Operator to Hyper
  #-----------------------------------------------

  def operator_to_hyper(name, param, precond_expression, effect_add, effect_del, define_operators)
    define_operators << "\n  def #{name}#{"(#{param.join(', ').delete!('?')})" unless param.empty?}"
    if effect_add.empty? and effect_del.empty?
      # Empty or sensing
      define_operators << (precond_expression ? "\n    #{precond_expression}\n  end\n" : "\n    true\n  end\n")
    else
      # Effective if preconditions hold
      define_operators << "\n    return unless #{precond_expression}" if precond_expression
      # Effective
      effect_calls = []
      effect_add.reject! {|pre| effect_calls << call(pre) if pre.first == 'call'}
      unless effect_add.empty? and effect_del.empty?
        define_operators << "\n    @state = @state.dup"
        apply('delete', effect_del, define_operators, duplicated = {})
        apply('unshift', effect_add, define_operators, duplicated)
      end
      define_operators << "\n    " << effect_calls.join(' and ') unless effect_calls.empty?
      define_operators << "\n  end\n"
    end
  end

  #-----------------------------------------------
  # Compile domain
  #-----------------------------------------------

  def compile_domain(domain_name, problem_name, operators, methods, predicates, state, tasks, axioms, rewards, attachments, hypertension_filename = "#{__dir__}/Hypertension_U")
    domain_str = "require_relative 'external' if File.exist?(\"\#{__dir__}/external.rb\")\n\nmodule #{domain_name.capitalize}\n  include Hypertension_U\n  extend self\n\n  ##{SPACER}\n  # Domain\n  ##{SPACER}\n\n  @domain = {\n    # Operators"
    # Operators
    define_operators = ''
    operators.each_with_index {|(name,param,precond_expression,*effects),i|
      precond_expression = precond_expression.empty? ? nil : expression_to_hyper(precond_expression, axioms)
      if effects.size == 3
        operator_to_hyper(name, param, precond_expression, effects.shift, effects.shift, define_operators)
        domain_str << "\n    '#{name}' => #{effects.shift}#{',' unless operators.size.pred == i and methods.empty?}"
      else
        domain_str << "\n    '#{name}' => {"
        while name = effects.shift
          operator_to_hyper(name, param, precond_expression, effects.shift, effects.shift, define_operators)
          domain_str << "\n      '#{name}' => #{effects.shift}#{',' unless effects.empty?}"
        end
        domain_str << "\n    }#{',' unless operators.size.pred == i and methods.empty?}"
      end
    }
    # Methods
    define_methods = ''
    domain_str << "\n    # Methods"
    methods.each_with_index {|(name,param,*decompositions),mi|
      domain_str << "\n    '#{name}' => [\n"
      paramstr = "(#{param.join(', ').delete!('?')})" unless param.empty?
      decompositions.each_with_index {|dec,i|
        domain_str << "      '#{name}_#{dec.first}'#{',' if decompositions.size - 1 != i}\n"
        define_methods << "\n  def #{name}_#{dec.first}#{paramstr}"
        # Obtain free variables
        # TODO refactor this block to work with complex expressions
        free_variables = []
        ground_variables = param.dup
        precond_attachments = []
        unless (precond_expression = dec[1]).empty?
          precond_expression = precond_expression.first == 'and' ? precond_expression.drop(1) : [precond_expression]
          precond_expression.reject! {|pre|
            pre = pre.last unless positive = pre.first != 'not'
            if attachments.assoc(pre.first)
              precond_attachments << pre.unshift(positive)
            elsif pre.first == 'assign'
              ground_variables << pre[1] if pre[2].flatten.all? {|j| not j.start_with?('?') or ground_variables.include?(j)}
              false
            elsif positive and pre.first != 'call' and not axioms.assoc(pre.first)
              free_variables.concat(pre.select {|j| j.instance_of?(String) and j.start_with?('?') and not ground_variables.include?(j)})
              false
            end
          }
        end
        free_variables.uniq!
        ground_free_variables = ground_variables + free_variables
        # Filter elements from precondition
        precond_pos = []
        precond_not = []
        lifted_axioms_calls = []
        ground_axioms_calls = []
        dependent_attachments = []
        precond_expression.each {|pre|
          if pre.first != 'not'
            pre_flat = pre.flatten
            precond = precond_pos
          else
            pre_flat = pre.last.flatten
            precond = precond_not
          end
          call_axiom = (assign = pre_flat.first == 'assign') || pre_flat.first == 'call' || axioms.assoc(pre_flat.first)
          pre_flat.select! {|t| t.start_with?('?') and not ground_variables.include?(t)}
          if pre_flat.empty? then ground_axioms_calls << pre
          elsif not pre_flat.all? {|t| free_variables.include?(t)}
            dependent_attachments << pre
            ground_free_variables << pre_flat.first if assign
          elsif call_axiom then lifted_axioms_calls << pre
          else precond << pre
          end
        }
        close_method_str = "\n  end\n"
        indentation = "\n    "
        if free_variables.empty?
          # Ground predicates, axioms and calls
          precond_pos.concat(precond_not).concat(ground_axioms_calls)
          define_methods << "\n    return unless " << expression_to_hyper(precond_pos.unshift('and'), axioms) unless precond_pos.empty?
        else
          # Ground axioms and calls
          define_methods << "\n    return unless " << expression_to_hyper(ground_axioms_calls.unshift('and'), axioms) unless ground_axioms_calls.empty?
          # Unify free variables
          precond_not.map!(&:last)
          equality = []
          define_methods_comparison = ''
          ground = param.dup
          until precond_pos.empty?
            pre, *terms = precond_pos.shift
            equality.clear
            define_methods_comparison.clear
            new_grounds = false
            terms2 = terms.map {|j|
              if not j.start_with?('?')
                equality << "_#{j}_ground != '#{j}'"
                "_#{j}_ground"
              elsif ground.include?(j)
                equality << "#{j}_ground != #{j}".delete!('?')
                evaluate("#{j}_ground", true)
              else
                new_grounds = true
                ground << free_variables.delete(j)
                evaluate(j, true)
              end
            }
            if new_grounds
              define_methods << "#{indentation}return" unless predicates[pre] or state.include?(pre)
              define_methods << "#{indentation}@state[#{evaluate(pre, true)}].each {|#{terms2.join(', ')},|"
              close_method_str.prepend("#{indentation}}")
              indentation << '  '
            elsif pre == '=' then equality << "#{terms2[0]} != #{terms2[1]}"
            elsif not predicates[pre] and not state.include?(pre) then define_methods << "#{indentation}return"
            else applicable(define_methods_comparison << "#{indentation}next unless ", pre, terms, predicates)
            end
            precond_pos.reject! {|pre,*terms|
              if (terms & free_variables).empty?
                if pre == '=' then equality << "#{evaluate(terms[0], true)} != #{evaluate(terms[1], true)}"
                elsif not predicates[pre] and not state.include?(pre) then define_methods << "#{indentation}return"
                else applicable(define_methods_comparison << "#{indentation}next unless ", pre, terms, predicates)
                end
              end
            }
            precond_not.reject! {|pre,*terms|
              if (terms & free_variables).empty?
                if pre == '=' then equality << "#{evaluate(terms[0], true)} == #{evaluate(terms[1], true)}"
                elsif predicates[pre] or state.include?(pre) then applicable(define_methods_comparison << "#{indentation}next if ", pre, terms, predicates)
                end
              end
            }
            define_methods << "#{indentation}next if #{equality.join(' or ')}" unless equality.empty?
            define_methods << define_methods_comparison
          end
          equality.clear
          define_methods_comparison.clear
          precond_not.each {|pre,*terms|
            if pre == '=' then equality << "#{evaluate(terms[0], true)} == #{evaluate(terms[1], true)}"
            elsif predicates[pre] or state.include?(pre) then applicable(define_methods_comparison << "#{indentation}next if ", pre, terms, predicates)
            end
          }
          define_methods << "#{indentation}next if #{equality.join(' or ')}" unless equality.empty?
          define_methods << define_methods_comparison
          define_methods << "#{indentation}next unless " << expression_to_hyper(lifted_axioms_calls.unshift('and'), axioms) unless lifted_axioms_calls.empty?
        end
        # Semantic attachments
        precond_attachments.each {|positive,pre,*terms|
          terms.map! {|t|
            if t.instance_of?(String) and t.start_with?('?') and not ground_free_variables.include?(t)
              ground_free_variables << t
              define_methods << "#{indentation}#{t.delete('?')} = ''"
            end
            evaluate(t, true)
          }
          if positive
            define_methods << "#{indentation}External.#{pre}(#{terms.join(', ')}) {"
            close_method_str.prepend("#{indentation}}")
            indentation << '  '
          else define_methods << "#{indentation}next if External.#{pre}(#{terms.join(', ')}) {break true}"
          end
        }
        unless dependent_attachments.empty?
          raise "Call with free variable in #{name} #{dec.first}" if dependent_attachments.flatten.any? {|t| t.start_with?('?') and not ground_free_variables.include?(t)}
          define_methods << "#{indentation}next unless " << expression_to_hyper(dependent_attachments.unshift('and'), axioms)
        end
        # Subtasks
        define_methods << subtasks_to_hyper(dec[2], indentation) << close_method_str
      }
      domain_str << (methods.size.pred == mi ? '    ]' : '    ],')
    }
    domain_str << "\n  }\n\n"
    # Rewards
    unless rewards.empty?
      domain_str << "  ##{SPACER}\n  # State valuation\n  ##{SPACER}\n\n  def state_valuation(old_state)\n    value = 0\n"
      rewards.each {|trigger,exp,value|
        exp = expression_to_hyper(exp, axioms)
        previous = exp.gsub('@','old_')
        case trigger
        when 'achieve' then domain_str << "    value += #{value} if not #{previous} and #{exp}\n"
        when 'maintain' then domain_str << "    value += #{value} if #{previous} and #{exp}\n"
        end
      }
      domain_str << "    value\n  end\n\n"
    end
    # Axioms
    unless axioms.empty?
      domain_str << "  ##{SPACER}\n  # Axioms\n  ##{SPACER}\n\n"
      axioms.each {|name,param,*expressions|
        domain_str << "  def #{name}#{"(#{param.join(', ').delete!('?')})" unless param.empty?}\n"
        expressions.each_slice(2) {|label,exp|
          domain_str << case exp = expression_to_hyper(exp, axioms)
          when 'false' then "    # #{label} is always false\n"
          when 'not false' then "    # #{label}\n    return true\n"
          else "    # #{label}\n    return true if #{exp}\n"
          end
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
    predicates.each_key {|i| state[i] ||= []}
    state.each_value {|k| k.each {|terms| objects.concat(terms)}}
    ordered = tasks.shift
    tasks.each {|_,*terms| objects.concat(terms)}
    # Objects
    objects.uniq!
    objects.each {|i|
      if i.instance_of?(String)
        problem_str << "#{i} = '#{i}'\n" if i !~ /^-?\d/
      else problem_str << "_#{i.join('_').tr(from,to)} = #{evaluate(i, true)}\n"
      end
    }
    problem_str << "\n#{domain_name.capitalize}.problem(\n  # Start\n  {\n"
    # Start
    state.each_with_index {|(k,v),i|
      problem_str << "    '#{k}' => ["
      problem_str << "\n      [" << v.map! {|obj| obj.map! {|o| o.instance_of?(String) ? o =~ /^-?\d/ ? "'#{o.to_f}'" : o : o.join('_').tr(from,to).prepend('_')}.join(', ')}.join("],\n      [") << "]\n    " unless v.empty?
      problem_str << (state.size.pred == i ? ']' : "],\n")
    }
    # Tasks
    problem_str << "\n  },\n  # Tasks\n  [" <<
      tasks.map! {|t| "\n    ['#{t.first}'#{', ' if t.size > 1}#{t.drop(1).map! {|o| o.instance_of?(String) ? o =~ /^-?\d/ ? "'#{o.to_f}'" : o : o.join('_').tr(from,to).prepend('_')}.join(', ')}]"}.join(',') <<
      "\n  ],\n  # Debug\n  ARGV.first == 'debug',\n  # Maximum plans found\n  ARGV[1] ? ARGV[1].to_i : -1,\n  # Minimum probability for plans\n  ARGV[2] ? ARGV[2].to_f : 0"
    tasks.unshift(ordered) unless tasks.empty?
    problem_str.gsub!(/\b-\b/,'_')
    domain_filename ? "# Generated by Hype\nrequire_relative '#{domain_filename}'\n\n#{problem_str}\n) or abort" : "#{problem_str}\n)"
  end
end