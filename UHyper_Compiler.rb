module UHyper_Compiler
  extend self

  SPACER = '-' * 47

  #-----------------------------------------------
  # Expression to Hyper
  #-----------------------------------------------

  def expression_to_hyper(precond_expression, axioms)
    case precond_expression[0]
    when 'and', 'or'
      if precond_expression.size == 2 then expression_to_hyper(precond_expression[1], axioms)
      else '(' << precond_expression.drop(1).map! {|exp| expression_to_hyper(exp, axioms)}.join(" #{precond_expression[0]} ") << ')'
      end
    when 'not' then (term = expression_to_hyper(precond_expression[1], axioms)).delete_prefix!('not ') or 'not ' << term
    when 'call' then call(precond_expression)
    when 'assign' then '(_' << precond_expression[1].delete_prefix('?') << ' = ' << evaluate(precond_expression[2]) << ')'
    when nil then 'false' # Empty list is false
    else
      terms = precond_expression.drop(1).map! {|i| evaluate(i)}.join(', ')
      if axioms.assoc(precond_expression[0]) then "#{precond_expression[0]}(#{terms})"
      else "@state[#{evaluate(precond_expression[0])}].include?([#{terms}])"
      end
    end
  end

  #-----------------------------------------------
  # Call
  #-----------------------------------------------

  def call(expression, namespace = '')
    case function = expression[1]
    # Binary math
    when '+', '-', '*', '/', '%', '^'
      raise "Expected 3 arguments for (#{expression.join(' ')})" if expression.size != 4
      ltoken = evaluate(expression[2], namespace, false)
      rtoken = evaluate(expression[3], namespace, false)
      if ltoken.match?(/^-?\d/) then ltoken = ltoken.to_f
      else ltoken.delete_suffix!('.to_s') or ltoken << '.to_f'
      end
      if rtoken.match?(/^-?\d/) then rtoken = rtoken.to_f
      else rtoken.delete_suffix!('.to_s') or rtoken << '.to_f'
      end
      function = '**' if function == '^'
      if ltoken.instance_of?(Float) and rtoken.instance_of?(Float) then ltoken.send(function, rtoken).to_s
      else "(#{ltoken} #{function} #{rtoken}).to_s"
      end
    # Unary math
    when 'abs', 'sin', 'cos', 'tan'
      raise "Expected 2 arguments for (#{expression.join(' ')})" if expression.size != 3
      ltoken = evaluate(expression[2], namespace, false)
      if ltoken.match?(/^-?\d/) then function == 'abs' ? ltoken.delete_prefix('-') : Math.send(function, ltoken.to_f).to_s
      elsif function == 'abs' then ltoken.sub!(/\.to_s$/,'.abs.to_s') or ltoken << ".delete_prefix('-')"
      else "Math.#{function}(#{ltoken.delete_suffix!('.to_s') or ltoken << '.to_f'}).to_s"
      end
    # Comparison
    when '=', '!=', '<', '>', '<=', '>='
      raise "Expected 3 arguments for (#{expression.join(' ')})" if expression.size != 4
      ltoken = evaluate(expression[2], namespace, false)
      rtoken = evaluate(expression[3], namespace, false)
      if ltoken == rtoken then (function == '=' or function == '<=' or function == '>=').to_s
      else
        function = '==' if function == '='
        if ltoken.match?(/^-?\d/)
          ltoken = ltoken.to_f
          return ltoken.send(function, rtoken.to_f).to_s if rtoken.match?(/^-?\d/)
          rtoken.delete_suffix!('.to_s') or rtoken << '.to_f'
        elsif rtoken.match?(/^-?\d/)
          rtoken = rtoken.to_f
          ltoken.delete_suffix!('.to_s') or ltoken << '.to_f'
        elsif function != '==' and function != '!='
          ltoken.delete_suffix!('.to_s') or ltoken << '.to_f'
          rtoken.delete_suffix!('.to_s') or rtoken << '.to_f'
        end
        "(#{ltoken} #{function} #{rtoken})"
      end
    # List
    when 'member'
      raise "Expected 3 arguments for (#{expression.join(' ')})" if expression.size != 4
      ltoken = evaluate(expression[2], namespace)
      rtoken = evaluate(expression[3], namespace)
      "#{rtoken}.include?(#{ltoken})"
    # External
    else "#{namespace}#{function}(#{expression.drop(2).map! {|term| evaluate(term, namespace)}.join(', ')})"
    end
  end

  #-----------------------------------------------
  # Evaluate
  #-----------------------------------------------

  def evaluate(term, namespace = '', quotes = true)
    if term.instance_of?(String)
      if term.start_with?('?') then term.tr('?','_')
      elsif term.match?(/^[a-z]/) then "'#{term}'"
      elsif term.match?(/^-?\d/) then quotes ? "'#{term.to_f}'" : term.to_f.to_s
      else term
      end
    elsif term[0] == 'call'
      term = call(term, namespace)
      quotes && term.match?(/^-?\d/) ? "'#{term}'" : term
    else "[#{term.map {|i| evaluate(i, namespace, quotes)}.join(', ')}]"
    end
  end

  #-----------------------------------------------
  # Applicable
  #-----------------------------------------------

  def applicable(output, pre, terms)
    output << "@state[#{evaluate(pre)}].include?([#{terms.map! {|t| evaluate(t)}.join(', ')}])"
  end

  #-----------------------------------------------
  # Apply
  #-----------------------------------------------

  def apply(modifier, effects, define_operators, duplicated)
    effects.each {|pre,*terms|
      pre_evaluated = evaluate(pre)
      if duplicated.include?(pre)
        define_operators << "\n    @state[#{pre_evaluated}]"
      else
        define_operators << "\n    (@state[#{pre_evaluated}] = @state[#{pre_evaluated}].dup)"
        duplicated[pre] = nil
      end
      define_operators << ".#{modifier}([#{terms.map! {|i| evaluate(i)}.join(', ')}])"
    }
  end

  #-----------------------------------------------
  # Operator to Hyper
  #-----------------------------------------------

  def operator_to_hyper(name, param, precond_expression, effect_add, effect_del, define_operators)
    define_operators << "\n  def #{name}#{"(#{param.join(', ').tr!('?','_')})" unless param.empty?}"
    if effect_add.empty? and effect_del.empty?
      # Empty or sensing
      define_operators << (precond_expression ? "\n    #{precond_expression}\n  end\n" : "\n    true\n  end\n")
    else
      # Effective if preconditions hold
      define_operators << "\n    return unless #{precond_expression}" if precond_expression
      # Effective
      effect_calls = []
      effect_add.reject! {|pre| effect_calls << call(pre) if pre[0] == 'call'}
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
      paramstr = "(#{param.join(', ').tr!('?','_')})" unless param.empty?
      decompositions.map! {|dec|
        define_methods << "\n  def #{name}_#{dec[0]}#{paramstr}"
        # Obtain free variables
        # TODO refactor this block to work with complex expressions
        free_variables = []
        precond_attachments = []
        precond_pos = []
        precond_not = []
        lifted_axioms_calls = []
        ground_axioms_calls = []
        dependent_attachments = []
        unless (precond_expression = dec[1]).empty?
          ground_variables = param.dup
          precond_expression = precond_expression[0] == 'and' ? precond_expression.drop(1) : [precond_expression]
          precond_expression.reject! {|pre|
            pre = pre[1] unless positive = pre[0] != 'not'
            if attachments.assoc(pre[0])
              precond_attachments << pre.unshift(positive)
            elsif pre[0] == 'assign'
              ground_variables << pre[1] if pre[2].flatten.all? {|j| not j.start_with?('?') or ground_variables.include?(j)}
              false
            elsif positive and pre[0] != 'call' and not axioms.assoc(pre[0])
              free_variables.concat(pre.select {|j| j.instance_of?(String) and j.start_with?('?') and not ground_variables.include?(j)})
              false
            end
          }
          free_variables.uniq!
          ground_free_variables = ground_variables + free_variables
          # Filter elements from precondition
          precond_expression.each {|pre|
            if pre[0] != 'not'
              pre_flat = pre.flatten
              precond = precond_pos
            else
              pre_flat = pre[1].flatten
              precond = precond_not
            end
            call_axiom = (assign = pre_flat[0] == 'assign') || pre_flat[0] == 'call' || axioms.assoc(pre_flat[0])
            pre_flat.select! {|t| t.start_with?('?') and not ground_variables.include?(t)}
            if pre_flat.empty? then ground_axioms_calls << pre
            elsif not pre_flat.all? {|t| free_variables.include?(t)}
              dependent_attachments << pre
              ground_free_variables << pre_flat[0] if assign
            elsif call_axiom then lifted_axioms_calls << pre
            else precond << pre
            end
          }
        end
        close_method_str = "\n  end\n"
        indentation = "\n    "
        if free_variables.empty?
          # Ground predicates, axioms and calls
          precond_pos.concat(precond_not, ground_axioms_calls)
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
                equality << "#{j = j.tr('?','_')}_ground != #{j}"
                "#{j}_ground"
              else
                ground << free_variables.delete(j)
                evaluate(j, new_grounds = true)
              end
            }
            if new_grounds
              define_methods << "#{indentation}return" unless predicates[pre] or state.include?(pre)
              define_methods << "#{indentation}@state[#{evaluate(pre)}].each {|#{terms2.join(', ')},|"
              close_method_str.prepend("#{indentation}}")
              indentation << '  '
            elsif pre == '=' then equality << "#{terms2[0]} != #{terms2[1]}"
            elsif not predicates[pre] and not state.include?(pre) then define_methods << "#{indentation}return"
            else applicable(define_methods_comparison << "#{indentation}next unless ", pre, terms)
            end
            precond_pos.reject! {|pre,*terms|
              if (terms & free_variables).empty?
                if pre == '=' then equality << "#{evaluate(terms[0])} != #{evaluate(terms[1])}"
                elsif not predicates[pre] and not state.include?(pre) then define_methods << "#{indentation}return"
                else applicable(define_methods_comparison << "#{indentation}next unless ", pre, terms)
                end
              end
            }
            precond_not.reject! {|pre,*terms|
              if (terms & free_variables).empty?
                if pre == '=' then equality << "#{evaluate(terms[0])} == #{evaluate(terms[1])}"
                elsif predicates[pre] or state.include?(pre) then applicable(define_methods_comparison << "#{indentation}next if ", pre, terms)
                end
              end
            }
            define_methods << "#{indentation}next if #{equality.join(' or ')}" unless equality.empty?
            define_methods << define_methods_comparison
          end
          equality.clear
          define_methods_comparison.clear
          precond_not.each {|pre,*terms|
            if pre == '=' then equality << "#{evaluate(terms[0])} == #{evaluate(terms[1])}"
            elsif predicates[pre] or state.include?(pre) then applicable(define_methods_comparison << "#{indentation}next if ", pre, terms)
            end
          }
          define_methods << "#{indentation}next if #{equality.join(' or ')}" unless equality.empty?
          define_methods << define_methods_comparison
          define_methods << "#{indentation}next unless " << expression_to_hyper(lifted_axioms_calls.unshift('and'), axioms) unless lifted_axioms_calls.empty?
        end
        # Semantic attachments
        precond_attachments.each {|positive,pre,*terms|
          terms.map! {|t|
            if t.instance_of?(String) and t.start_with?('?')
              td = t.tr('?','_')
              unless ground_free_variables.include?(t)
                ground_free_variables << t
                define_methods << "#{indentation}#{td} = ''"
              end
              td
            else evaluate(t)
            end
          }
          if positive
            define_methods << "#{indentation}#{pre}(#{terms.join(', ')}) {"
            close_method_str.prepend("#{indentation}}")
            indentation << '  '
          else define_methods << "#{indentation}next if #{pre}(#{terms.join(', ')}) {break true}"
          end
        }
        unless dependent_attachments.empty?
          raise "Call with free variable in #{name} #{dec[0]}" if dependent_attachments.flatten.any? {|t| t.start_with?('?') and not ground_free_variables.include?(t)}
          define_methods << "#{indentation}next unless " << expression_to_hyper(dependent_attachments.unshift('and'), axioms)
        end
        # Subtasks
        define_methods << indentation << (dec[2].empty? ? 'yield []' : "yield [#{indentation}  [" << dec[2].map {|g| g.map {|i| evaluate(i)}.join(', ')}.join("],#{indentation}  [") << "]#{indentation}]") << close_method_str
        "\n      '#{name}_#{dec[0]}'"
      }
      domain_str << "\n    '#{name}' => [" << decompositions.join(',') << (methods.size.pred == mi ? "\n    ]" : "\n    ],")
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
        else raise "Unexpected #{trigger} as reward trigger"
        end
      }
      domain_str << "    value\n  end\n\n"
    end
    # Axioms
    unless axioms.empty?
      domain_str << "  ##{SPACER}\n  # Axioms\n  ##{SPACER}\n\n"
      axioms.each {|name,param,*expressions|
        domain_str << "  def #{name}#{"(#{param.join(', ').tr!('?','_')})" unless param.empty?}\n"
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
    problem_str = "# Objects\n"
    # Extract information
    objects = []
    state.each_value {|v| objects.concat(*v)}
    ordered = tasks.shift
    tasks.each {|_,*terms| objects.concat(terms)}
    # Objects
    objects.uniq!
    objects.each {|i| problem_str << "_#{i} = '#{i}'\n" if i.instance_of?(String) and not i.match?(/^-?\d/)}
    problem_str << "\n#{namespace = "#{domain_name.capitalize}."}problem(\n  # Start\n  {"
    # Start
    predicates.each_key {|i| state[i] ||= []}
    state.each_with_index {|(k,v),i|
      problem_str << "\n    '#{k}' => ["
      problem_str << "\n      [" << v.map! {|obj| obj.map! {|o| o.instance_of?(String) ? o.match?(/^-?\d/) ? "'#{o.to_f}'" : '_' << o : evaluate(o, namespace)}.join(', ')}.join("],\n      [") << "]\n    " unless v.empty?
      problem_str << (state.size.pred == i ? ']' : '],')
    }
    # Tasks
    problem_str << "\n  },\n  # Tasks\n  [" <<
      tasks.map! {|task,*terms| "\n    ['#{task}'#{terms.map! {|o| o.instance_of?(String) ? o.match?(/^-?\d/) ? ", '#{o.to_f}'" : ', _' << o : ', ' << evaluate(o, namespace)}.join}]"}.join(',') <<
      "\n  ],\n  # Debug\n  ARGV[0] == 'debug',\n  # Maximum plans found\n  ARGV[1] ? ARGV[1].to_i : -1,\n  # Minimum probability for plans\n  ARGV[2] ? ARGV[2].to_f : 0#{",\n  # Ordered\n  false" if ordered == false}"
    tasks.unshift(ordered) unless tasks.empty?
    problem_str.gsub!(/\b-\b/,'_')
    domain_filename ? "# Generated by Hype\nrequire_relative '#{domain_filename}'\n\n#{problem_str}\n)" : "#{problem_str}\n)"
  end
end