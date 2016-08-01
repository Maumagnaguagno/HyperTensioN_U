module UHyper_Compiler
  extend self

  SPACER = '-' * 47

  #-----------------------------------------------
  # Predicates to Hyper
  #-----------------------------------------------

  def predicates_to_hyper(output, predicates)
    if predicates.empty?
      output << "\n      []"
    else
      group = []
      predicates.each {|g| group << g.map {|i| i.start_with?('?') ? i.sub(/^\?/,'') : "'#{i}'"}.join(', ')}
      output << "\n      [\n        [" << group.join("],\n        [") << "]\n      ]"
    end
  end

  #-----------------------------------------------
  # Subtasks to Hyper
  #-----------------------------------------------

  def subtasks_to_hyper(output, subtasks, indentation)
    if subtasks.empty?
      output << "#{indentation}yield []\n"
    else
      group = []
      subtasks.each {|t| group << t.map {|i| i.start_with?('?') ? i.sub(/^\?/,'') : "'#{i}'"}.join(', ')}
      output << "#{indentation}yield [\n#{indentation}  [" << group.join("],\n#{indentation}  [") << "]\n#{indentation}]\n"
    end
  end

  #-----------------------------------------------
  # Subtasks to Hyper
  #-----------------------------------------------

  def expression_to_hyper(precond_expression, axioms)
    case precond_expression.first
    when 'and', 'or'
      '(' << precond_expression.drop(1).map {|exp| expression_to_hyper(exp, axioms)}.join(" #{precond_expression.first} ") << ')'
    when 'not'
      'not (' << expression_to_hyper(precond_expression[1], axioms) << ')'
    when 'call'
      # TODO recursive calls
      function = '==' if (function = precond_expression[1]) == '='
      terms = precond_expression.drop(2).map! {|i| i.start_with?('?') ? i.sub(/^\?/,'') : "'#{i}'"}
      "(#{terms.first} #{function} #{terms.last})"
    else
      if precond_expression.empty?
        'true'
      else
        terms = precond_expression.drop(1).map! {|i| i.start_with?('?') ? i.sub(/^\?/,'') : "'#{i}'"}.join(', ')
        if axioms.assoc(precond_expression.first)
          "#{precond_expression.first}(#{terms})"
        else
          "@state['#{precond_expression.first}'].include?([#{terms}])"
        end
      end
    end
  end

  #-----------------------------------------------
  # Operators to Hyper
  #-----------------------------------------------

  def operator_to_hyper(name, param, precond_expression, effect_pos, effect_not, axioms, define_operators)
    define_operators << "\n  def #{name}#{"(#{param.map {|j| j.sub(/^\?/,'')}.join(', ')})" unless param.empty?}\n"
    if effect_pos.empty? and effect_not.empty?
      if precond_expression.empty?
        # Empty
        define_operators << "    true\n  end\n"
      else
        # Sensing
        define_operators << "    #{expression_to_hyper(precond_expression, axioms)}\n  end\n"
      end
    else
      unless precond_expression.empty?
        # Effective if preconditions hold
        define_operators << "    return unless #{expression_to_hyper(precond_expression, axioms)}\n"
      end
      # Effective
      define_operators << '    apply('
      predicates_to_hyper(define_operators << "\n      # Add effects", effect_pos)
      predicates_to_hyper(define_operators << ",\n      # Del effects", effect_not)
      define_operators << "\n    )\n  end\n"
    end
  end

  #-----------------------------------------------
  # Compile domain
  #-----------------------------------------------

  def compile_domain(domain_name, problem_name, operators, methods, predicates, state, tasks, goal_pos, goal_not, axioms, reward, hypertension_filename = File.expand_path('../Hypertension_U', __FILE__))
    domain_str = "module #{domain_name.capitalize}\n  include Hypertension_U\n  extend self\n\n  ##{SPACER}\n  # Domain\n  ##{SPACER}\n\n  @domain = {\n    # Operators"
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
      met.drop(2).each_with_index {|met_case,i|
        domain_str << "      '#{met_case.first}'#{',' if met.size - 3 != i}\n"
        define_methods << "\n  def #{met_case.first}#{variables}\n"
        # No preconditions
        if met_case[2].empty? and met_case[3].empty?
          subtasks_to_hyper(define_methods, met_case[4], '    ')
        # Ground
        elsif met_case[1].empty?
          predicates_to_hyper(define_methods << "    if applicable?(\n      # Positive preconditions", met_case[2])
          predicates_to_hyper(define_methods << ",\n      # Negative preconditions", met_case[3])
          subtasks_to_hyper(define_methods << "\n    )\n", met_case[4], '      ')
          define_methods << "    end\n"
        # Lifted
        else
          met_case[1].each {|free| define_methods << "    #{free.sub(/^\?/,'')} = ''\n"}
          predicates_to_hyper(define_methods << "    generate(\n      # Positive preconditions", met_case[2])
          predicates_to_hyper(define_methods << ",\n      # Negative preconditions", met_case[3])
          met_case[1].each {|free| define_methods << ", #{free.sub(/^\?/,'')}"}
          subtasks_to_hyper(define_methods << "\n    ) {\n", met_case[4], '      ')
          define_methods << "    }\n"
        end
        define_methods << "  end\n"
      }
      domain_str << (methods.size.pred == mi ? '    ]' : '    ],')
    }
    domain_str << "\n  }\n\n"
    # Reward
    unless reward.empty?
      domain_str << "  ##{SPACER}\n  # State valuation\n  ##{SPACER}\n\n  def state_valuation\n    value = 0\n"
      reward.each {|pre,value| domain_str << "    value += #{value} if not @previous_state['#{pre.first}'].include?(#{pre.drop(1)}) and @state['#{pre.first}'].include?(#{pre.drop(1)})\n"}
      domain_str << "    value\n  end\n\n"
    end
    # Axioms
    unless axioms.empty?
      domain_str << "  ##{SPACER}\n  # Axioms\n  ##{SPACER}\n\n"
      axioms.each {|name,params,*expressions|
        domain_str << "  def #{name}(#{params.map {|i| i.sub(/^\?/,'')}.join(', ')})\n"
        expressions.each {|exp| domain_str << "    return true if #{expression_to_hyper(exp, axioms)}\n"}
        domain_str << "  end\n\n"
      }
    end
    # Definitions
    domain_str << "  ##{SPACER}\n  # Operators\n  ##{SPACER}\n#{define_operators}\n  ##{SPACER}\n  # Methods\n  ##{SPACER}\n#{define_methods}end"
    domain_str.gsub!(/\b-\b/,'_')
    hypertension_filename ? "# Generated by Hype\nrequire '#{hypertension_filename}'\n\n#{domain_str}" : domain_str
  end

  #-----------------------------------------------
  # Compile problem
  #-----------------------------------------------

  def compile_problem(domain_name, problem_name, operators, methods, predicates, state, tasks, goal_pos, goal_not, axioms, reward, domain_filename = nil)
    problem_str = "# Objects\n"
    # Extract information
    objects = []
    start_hash = Hash.new {|h,k| h[k] = []}
    predicates.each_key {|i| start_hash[i] = []}
    state.each {|pred,*terms|
      start_hash[pred] << terms
      objects.concat(terms)
    }
    goal_pos.each {|pred,*terms|
      start_hash[pred]
      objects.concat(terms)
    }
    goal_not.each {|pred,*terms|
      start_hash[pred]
      objects.concat(terms)
    }
    ordered = tasks.shift
    tasks.each {|pred,*terms| objects.concat(terms)}
    # Objects
    objects.uniq!
    objects.each {|i| problem_str << "#{i} = '#{i}'\n"}
    problem_str << "\n#{domain_name.capitalize}.problem(\n  # Start\n  {\n"
    # Start
    start_hash.each_with_index {|(k,v),i|
      problem_str << "    '#{k}' => ["
      problem_str << "\n      [" << v.map! {|obj| obj.join(', ')}.join("],\n      [") << "]\n    " unless v.empty?
      problem_str << (start_hash.size.pred == i ? ']' : "],\n")
    }
    # Tasks
    group = []
    tasks.each {|t| group << "    ['#{t.first}'#{', ' if t.size > 1}#{t.drop(1).join(', ')}]"}
    problem_str << "\n  },\n  # Tasks\n  [\n" << group .join(",\n") << "\n  ],\n  # Debug\n  ARGV.first == '-d',\n  # Minimal probability for plans\n  ARGV[1] ? ARGV[1].to_f : 0,\n  # Maximum plans found\n  ARGV[2] ? ARGV[2].to_i : -1"
    tasks.unshift(ordered) unless tasks.empty?
    unless ordered
      group.clear
      goal_pos.each {|g| group << "    ['#{g.first}', #{g.drop(1).join(', ')}]"}
      problem_str << ",\n  # Positive goals\n  [\n" << group.join(",\n") << "\n  ],\n  # Negative goals\n  [\n"
      group.clear
      goal_not.each {|g| group << "    ['#{g.first}', #{g.drop(1).join(', ')}]"}
      problem_str << group.join(",\n") << "\n  ]"
    end
    problem_str.gsub!(/\b-\b/,'_')
    domain_filename ? "# Generated by Hype\nrequire_relative '#{domain_filename}'\n\n#{problem_str}\n)" : "#{problem_str}\n)"
  end
end