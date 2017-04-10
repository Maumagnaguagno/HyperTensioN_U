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
require_relative 'steps-methods'

COMMITMENTS = [
  C1 = 'C1',
  C2 = 'C2',
  C3 = 'C3',
  C4 = 'C4',
  C5 = 'C5',
  C6 = 'C6',
  C7 = 'C7',
  C8 = 'C8',
  #C9 = 'C9',
  #C10 = 'C10',
  #C11 = 'C11',
  #C12 = 'C12'
]

GOALS = [
  G1 = 'G1',
  G2 = 'G2',
  G3 = 'G3',
  G4 = 'G4',
  # G5 = 'G5',
  G6 = 'G6',
  G7 = 'G7',
  G8 = 'G8',
  G9 = 'G9',
  #G10 = 'G10',
  G11 = 'G11',
  G12 = 'G12',
  G13 = 'G13',
  #G14 = 'G14',
  G15 = 'G15',
  G16 = 'G16',
  G17 = 'G17',
  G18 = 'G18',
  G19 = 'G19'
]

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
    'invisible_testSuccessG' => 1,
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
    'performImaging' => {
      'performImaging_success' => 0.7,
      'performImaging_failure' => 0.3
    },
    'performBiopsy' => {
      'performBiopsy_success' => 0.6,
      'performBiopsy_failure' => 0.4
    },
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
    'detach' => [
      'detach_case0',
      'detach_case1'
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
    ],
    'step1' => [
      'step1'
    ],
    'step2' => [
      'step2'
    ],
    'step3' => [
      'step3'
    ],
    'step4' => [
      'step4'
    ],
    'step5' => [
      'step5'
    ],
  }

  def state(pre, *terms)
    @state[pre].include?(terms)
  end
end