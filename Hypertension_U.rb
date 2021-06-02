#-----------------------------------------------
# HyperTensioN U
#-----------------------------------------------
# Mau Magnaguagno
#-----------------------------------------------
# HTN planner
#-----------------------------------------------

require_relative '../HyperTensioN/Hypertension'

module Hypertension_U
  include Hypertension
  extend self

  attr_accessor :min_prob, :max_plans, :plans

  # Probabilistic plan = [PROBABILITY = 1, VALUATION = 0, op0, ..., opN]
  PROBABILITY = 0
  VALUATION   = 1

  #-----------------------------------------------
  # Planning
  #-----------------------------------------------

  def planning(tasks, level = 0, plan = [1,0])
    # Limit test
    if @plans.size != @max_plans
      if tasks.empty?
        if plan[PROBABILITY] >= @min_prob
          puts "#{'  ' * level}plan found" if @debug
          @plans << plan
        end
      else
        case decomposition = @domain[(current_task = tasks.shift).first]
        # Operator with single outcome
        when Numeric
          execute(current_task, decomposition, tasks, level, plan)
        # Operator with multiple outcomes
        when Hash
          task_name = current_task.first
          begin
            decomposition.each {|task_prob,probability|
              current_task[0] = task_prob
              execute(current_task, probability, tasks, level, plan)
              return if @plans.size == @max_plans
            }
          rescue SystemStackError then @nostack = true
          end
          current_task[0] = task_name
        # Method
        when Array
          # Keep decomposing the hierarchy
          task_name = current_task.shift
          plans_found = @plans.size
          level += 1
          begin
            decomposition.each {|method|
              puts "#{'  ' * level.pred}#{method}(#{current_task.join(' ')})" if @debug
              # Every unification is tested
              send(method, *current_task) {|subtasks|
                planning(subtasks.concat(tasks), level, plan)
                return if @plans.size == @max_plans
              }
              # Consider success when at least one new plan was found
              break if @plans.size != plans_found
            }
          rescue SystemStackError then @nostack = true
          end
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

  def state_valuation(old_state)
    0
  end

  #-----------------------------------------------
  # Execute
  #-----------------------------------------------

  def execute(current_task, probability, tasks, level, plan)
    old_state = @state
    puts "#{'  ' * level}#{current_task.first}(#{current_task.drop(1).join(' ')})" if @debug
    begin
      # Minimum probability and applied
      if (new_prob = plan[PROBABILITY] * probability) >= @min_prob and send(*current_task)
        new_plan = plan.dup << current_task.map(&:dup)
        new_plan[PROBABILITY] = new_prob
        new_plan[VALUATION] += state_valuation(old_state) * probability
        # Keep decomposing the hierarchy
        planning(tasks, level, new_plan)
      end
    rescue SystemStackError then @nostack = true
    end
    @state = old_state
  end

  #-----------------------------------------------
  # Problem
  #-----------------------------------------------

  def problem(state, tasks, debug = false, max_plans = -1, min_prob = 0)
    @nostack = false
    @debug = debug
    @state = state
    @min_prob = min_prob
    @max_plans = max_plans
    @plans = []
    puts 'Tasks'.center(50,'-')
    print_data(tasks)
    puts 'Planning'.center(50,'-')
    t = Time.now.to_f
    planning(tasks)
    puts "Time: #{Time.now.to_f - t}s", "Plans found: #{@plans.size}"
    @plans.each_with_index {|(probability,valuation,*plan),i|
      puts "Plan #{i.succ}".center(50,'-'),
           "Probability: #{probability}",
           "Valuation: #{valuation}"
      if plan.empty? then puts 'Empty plan'
      else print_data(plan.delete_if {|op| op.first.start_with?('invisible_')})
      end
    }
    puts @nostack ? 'Planning failed, try with more stack' : 'Planning failed' if @plans.empty?
    @plans
  rescue Interrupt
    puts 'Interrupted'
  rescue
    puts $!, $@
  end
end