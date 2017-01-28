require_relative '../../Hypertension_U'

def list(*terms)
  "(#{terms.join(' ')})"
end

require_relative 'equality-axioms'
require_relative 'commitment-axioms'
require_relative 'healthcare-axioms'
require_relative 'commitment-operators'
require_relative 'goal-axioms'
require_relative 'goal-operators'
require_relative 'goal-methods'
require_relative 'goal-commitment-methods'
require_relative 'test-methods'
require_relative 'healthcare-methods'
require_relative 'healthcare-operators'

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

    'requestAssessment' => 1,
    'requestImaging' => 1,
    'requestBiopsy' => 1,
    'performImaging' => 0.7,
    'performBiopsy' => 0.6,
    'requestPathologyReport' => 1,
    'requestRadiologyReport' => 1,
    'sendPathologyReport' => 1,
    'sendRadiologyReport' => 1,
    'sendIntegratedReport' => 1,
    'generateTreatmentPlan' => 1,
    'reportPatient' => 1,
    'addPatientToRegistry' => 1,
    'escalateFailure' => 1,
    'requestPhysicianReportAssessment' => 1,
    'requestRadiologyReportAssessment' => 1,
    'requestPathologyReportAssessment' => 1,
    # Methods
    'achieveGoals' => [
      'achieveGoals_workTowardsGoal',
      'achieveGoals_activateGoal',
      'achieveGoals_noGoalsPossible',
      'achieveGoals_multipleCommitments'
    ],
    'achieveGoal' => [
      'genericEnticeToAchieve',
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
    ],

    'hospitalScenario' => [
      'hospitalScenario_case0'
    ],
    'testCommitments' => [
      'testCommitments_case0'
    ],
    'seekHelp' => [
      'seekHelp_case0'
    ],
    'processPatient' => [
      'processPatient_process_patient_healthy'
    ],
    'performImagingTests' => [
      'performImagingTests_imaging',
    ],
    'performPathologyTests' => [
      'performPathologyTests_biopsy_unnecessary',
      'performPathologyTests_imaging_plus_biopsy'
    ],
    'attendTest' => [
      'attendTest_attend_imaging',
      'attendTest_attend_biopsy',
      'attendTest_no_show_imaging',
      'attendTest_no_show_biopsy'
    ],
    'deliverDiagnostics' => [
      'deliverDiagnostics_only_imaging',
      'deliverDiagnostics_imaging_biopsy_integrated'
    ]
  }

  def state(pre, *terms)
    @state[pre].include?(terms)
  end
end