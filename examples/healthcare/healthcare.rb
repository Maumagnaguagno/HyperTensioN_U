require_relative 'commitment-axioms'
require_relative 'healthcare-axioms'
require_relative 'commitment-operators'
require_relative 'goal-axioms'
#require_relative 'goal-operators'

module Healthcare
  include Hypertension
  extend self

  #-----------------------------------------------
  # Domain
  #-----------------------------------------------

  @domain = {
    # Operators
    invisible_testSuccess => 1,
    invisible_testFailure => 1,
    create => 1,
    suspend => 1,
    reactivate => 1,
    satisfy => 1,
    expire => 1,
    timeoutviolate => 1,
    cancel => 1,
    release => 1
    # Methods
    
  }

  def state(pre, *terms)
    @state[pre].include?(terms)
  end
end