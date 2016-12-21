require_relative 'commitment-axioms'
require_relative 'healthcare-axioms'
require_relative 'commitment-operators'
#require_relative 'goal-axioms'
#require_relative 'goal-operators'

def state(pre, *terms)
  @state[pre].include?(terms)
end