require_relative '../../Hypertension_U'

require_relative 'commitment-axioms'
require_relative 'healthcare-axioms'
require_relative 'commitment-operators'
require_relative 'goal-axioms'
require_relative 'goal-operators'
require_relative 'goal-methods'
require_relative 'goal-commitment-methods'
require_relative 'test-methods'
require_relative 'healthcare-methods'

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
    ],
    'entice' => [
      'entice_case0'
    ],
    'suspendOffer' => [
      'suspendOffer_case0'
    ],
    'revive' => [
      'revive_case0'
    ],
    'withdrawOffer' => [
      'withdrawOffer_case0'
    ],
    'reviveToWithdraw' => [
      'reviveToWithdraw_case0'
    ],
    'negotiate' => [
      'negotiate_case0'
    ],
    'abandonEndGoal' => [
      'abandonEndGoal_case0'
    ],
    'deliver' => [
      'deliver_case0',
      'deliver_case1'
    ],
    'backBurner' => [
      'backBurner_case0'
    ],
    'frontBurner' => [
      'frontBurner_case0'
    ],
    'abandonMeansGoal' => [
      'abandonMeansGoal_case0'
    ],
    'persist' => [
      'persist_case0'
    ],
    'giveUp' => [
      'giveUp_case0'
    ],

    'testCommitment' => [
      'testCommitment_case0'
    ],
    'testGoal' => [
      'testGoal_case0'
    ],
    'testGoalCommitmentRule' => [
      'testGoalCommitmentRule_case0'
    ]
  }

  def state(pre, *terms)
    @state[pre].include?(terms)
  end
end