require_relative '../../Hypertension_U'

require_relative 'commitment-axioms'
require_relative 'healthcare-axioms'
require_relative 'commitment-operators'
require_relative 'goal-axioms'
require_relative 'goal-operators'
require_relative 'goal-methods'

module Healthcare
  include Hypertension_U
  extend self

  #-----------------------------------------------
  # Domain
  #-----------------------------------------------

  @domain = {
    # Operators
    'invisible_testSuccess' => 1,
    'invisible_testFailure' => 1,
    'create' => 1,
    'suspend' => 1,
    'reactivate' => 1,
    'satisfy' => 1,
    'expire' => 1,
    'timeoutviolate' => 1,
    'cancel' => 1,
    'release' => 1,

    'testSuccessG' => 1,
    'consider' => 1,
    'activate' => 1,
    'suspendG' => 1,
    'reconsider' => 1,
    'reactivateG' => 1,
    'drop' => 1,
    'abort' => 1,
    # Methods
    'achieveGoals' => [
      'achieveGoals_workTowardsGoal',
      'achieveGoals_activateGoal',
      'achieveGoals_noGoalsPossible',
      'achieveGoals_multipleCommitments'
    ],
    'achieveGoal' => [
      'genericEnticeToAchieve',
      'achieveGoal_case1',
      'achieveGoal_case2',
      'achieveGoal_case3',
    ],
    'detach' => [
      'detach_case0'
    ]
  }

  def state(pre, *terms)
    @state[pre].include?(terms)
  end
end