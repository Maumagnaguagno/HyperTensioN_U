module Hypertension_U
  extend self

  attr_accessor :domain, :state, :min_prob, :max_found, :plans, :debug

  # Probabilistic plan = [PROBABILITY = 1, VALUATION = 0, op0, ..., opN]
  PROBABILITY = 0
  VALUATION   = 1

  #-----------------------------------------------
  # Planning
  #-----------------------------------------------

  def planning(tasks, level = 0, plan = [1,0])
    # Limit test
    if @plans.size != @max_found
      if tasks.empty?
        @plans << plan if plan[PROBABILITY] >= @min_prob
      else
        case decomposition = @domain[(current_task = tasks.shift).first]
        # Operator with single outcome
        when Numeric
          execute(current_task, decomposition, tasks, level, plan)
        # Operator with multiple outcomes
        when Hash
          decomposition.each {|task_prob,probability|
            current_task.first.replace(task_prob)
            execute(current_task, probability, tasks, level, plan)
          }
        # Method
        when Array
          # Keep decomposing the hierarchy
          task_name = current_task.shift
          level += 1
          decomposition.each {|method|
            puts "#{'  ' * level.pred}#{method}(#{current_task.join(',')})" if @debug
            # Every unification is tested
            send(method, *current_task) {|subtasks| return true if planning(subtasks.concat(tasks), level, plan)}
          }
          current_task.unshift(task_name)
        # Error
        else raise "Domain defines no decomposition for #{current_task.first}"
        end
      end
    end
  end

  #-----------------------------------------------
  # State valuation
  #-----------------------------------------------

  def state_valuation
    0
  end

  #-----------------------------------------------
  # Execute
  #-----------------------------------------------

  def execute(current_task, probability, tasks, level, plan)
    puts "#{'  ' * level}#{current_task.first}(#{current_task.drop(1).join(',')})" if @debug
    if (new_prob = plan[PROBABILITY] * probability) >= @min_prob
      # If operator applied
      @previous_state = @state
      if new_state = send(*current_task)
        new_plan = plan.dup << current_task
        new_plan[PROBABILITY] = new_prob
        new_plan[VALUATION] += state_valuation * probability
        # Keep decomposing the hierarchy
        planning(tasks, level, new_plan)
      end
    end
  end

  #-----------------------------------------------
  # Applicable?
  #-----------------------------------------------

  def applicable?(precond_pos, precond_not)
    # All positive preconditions and no negative preconditions are found in the state
    precond_pos.all? {|name,*objs| @state[name].include?(objs)} and precond_not.none? {|name,*objs| @state[name].include?(objs)}
  end

  #-----------------------------------------------
  # Apply
  #-----------------------------------------------

  def apply(effect_add, effect_del)
    # Create new state with added or deleted predicates
    @state = Marshal.load(Marshal.dump(@state))
    effect_del.each {|name,*objs| @state[name].delete(objs)}
    effect_add.each {|name,*objs| @state[name] << objs}
    true
  end

  #-----------------------------------------------
  # Apply operator
  #-----------------------------------------------

  def apply_operator(precond_pos, precond_not, effect_add, effect_del)
    # Apply effects if preconditions satisfied
    apply(effect_add, effect_del) if applicable?(precond_pos, precond_not)
  end

  #-----------------------------------------------
  # Generate
  #-----------------------------------------------

  def generate(precond_pos, precond_not, *free)
    # Free variable to set of values
    objects = free.map {|i| [i]}
    # Unification by positive preconditions
    match_objects = []
    precond_pos.each {|name,*terms|
      next unless terms.include?('')
      # Swap free variables with matching set or maintain constant term
      terms.map! {|p| objects.find {|j| j.first.equal?(p)} or p}
      # Compare with current state
      @state[name].each {|objs|
        next unless terms.each_with_index {|t,i|
          # Free variable
          if t.instance_of?(Array)
            # Not unified
            if t.first.empty?
              match_objects.push(t, i)
            # No match with previous unification
            elsif not t.include?(objs[i])
              match_objects.clear
              break
            end
          # No match with value
          elsif t != objs[i]
            match_objects.clear
            break
          end
        }
        # Add values to sets
        match_objects.shift << objs[match_objects.shift] until match_objects.empty?
      }
      # Unification closed
      terms.each {|i| i.first.replace('X') if i.instance_of?(Array) and i.first.empty?}
    }
    # Remove pointer and duplicates
    objects.each {|i|
      i.shift
      return if i.empty?
      i.uniq!
    }
    # Depth-first search
    stack = []
    level = obj = 0
    while level
      # Replace pointer value with useful object to affect variables
      free[level].replace(objects[level][obj])
      if level != free.size.pred
        # Stack backjump position
        stack.unshift(level, obj.succ) if obj.succ != objects[level].size
        level += 1
        obj = 0
      else
        yield if applicable?(precond_pos, precond_not)
        # Load next object or restore
        if (obj += 1) == objects[level].size
          level = stack.shift
          obj = stack.shift
        end
      end
    end
  end

  #-----------------------------------------------
  # Print data
  #-----------------------------------------------

  def print_data(data)
    data.each_with_index {|d,i| puts "#{i}: #{d.first}(#{d.drop(1).join(', ')})"}
  end

  #-----------------------------------------------
  # Problem
  #-----------------------------------------------

  def problem(start, tasks, debug = false, min_prob = 0, max_found = -1)
    @debug = debug
    @state = start
    @min_prob = min_prob
    @max_found = max_found
    @plans = []
    puts 'Tasks'.center(50,'-')
    print_data(tasks)
    puts 'Planning'.center(50,'-')
    t = Time.now.to_f
    planning(tasks)
    puts "Time: #{Time.now.to_f - t}s", 'Plan'.center(50,'-')
    puts "Plans found: #{@plans.size}"
    @plans.each_with_index {|plan,i|
      puts "Plan #{i}".center(50,'-'),
           "Valuation: #{plan[VALUATION]}",
           "Probability: #{plan[PROBABILITY]}"
      if plan.size == 2
        puts 'Empty plan'
      else print_data(plan.drop(2))
      end
    }
    puts 'Planning failed' if @plans.empty?
    @plans
  rescue Interrupt
    puts 'Interrupted'
  rescue
    puts $!, $@
  end
end