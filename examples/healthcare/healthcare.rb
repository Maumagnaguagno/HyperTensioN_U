# Both planners can execute this domain
require_relative '../../Hypertension_U'
#require_relative '../../../Hypertension/Hypertension'

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
  #G5 = 'G5',
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

  #-----------------------------------------------
  # Domain
  #-----------------------------------------------

  if defined?(Hypertension_U)
    include Hypertension_U
    VISIBLE = INVISIBLE = 1
    PERFORMIMAGING_OUTCOMES = {
      'performImaging_success' => 0.7,
      'performImaging_failure' => 0.3
    }
    PERFORMBIOPSY_OUTCOMES = {
      'performBiopsy_success' => 0.6,
      'performBiopsy_failure' => 0.4
    }
  else
    include Hypertension
    VISIBLE = true
    INVISIBLE = false
    PERFORMIMAGING_OUTCOMES = PERFORMBIOPSY_OUTCOMES = VISIBLE
  end
  extend self

  @domain = {
    # Operators
    'invisible_testSuccess' => INVISIBLE,
    'invisible_testFailure' => INVISIBLE,
    'invisible_testSuccessG' => INVISIBLE,
    'create' => VISIBLE,
    'suspend' => VISIBLE,
    'reactivate' => VISIBLE,
    'satisfy' => VISIBLE,
    'expire' => VISIBLE,
    'timeoutviolate' => VISIBLE,
    'cancel' => VISIBLE,
    'release' => VISIBLE,

    'testSuccessG' => VISIBLE,
    'consider' => VISIBLE,
    'activate' => VISIBLE,
    'suspendG' => VISIBLE,
    'reconsider' => VISIBLE,
    'reactivateG' => VISIBLE,
    'drop' => VISIBLE,
    'abort' => VISIBLE,

    'requestAssessment' => VISIBLE,
    'requestImaging' => VISIBLE,
    'requestBiopsy' => VISIBLE,
    'performImaging' => PERFORMIMAGING_OUTCOMES,
    'performBiopsy' => PERFORMBIOPSY_OUTCOMES,
    'requestPathologyReport' => VISIBLE,
    'requestRadiologyReport' => VISIBLE,
    'sendPathologyReport' => VISIBLE,
    'sendRadiologyReport' => VISIBLE,
    'sendIntegratedReport' => VISIBLE,
    'generateTreatmentPlan' => VISIBLE,
    'reportPatient' => VISIBLE,
    'addPatientToRegistry' => VISIBLE,
    'escalateFailure' => VISIBLE,
    'requestPhysicianReportAssessment' => VISIBLE,
    'requestRadiologyReportAssessment' => VISIBLE,
    'requestPathologyReportAssessment' => VISIBLE,
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


  #-----------------------------------------------
  # State valuation
  #-----------------------------------------------

  def state_valuation(old_state)
    previous_iAppointmentKept = old_state['iAppointmentKept']
    current_iAppointmentKept = @state['iAppointmentKept']
    previous_bAppointmentKept = old_state['bAppointmentKept']
    current_bAppointmentKept = @state['bAppointmentKept']
    value = 0
    value += 10 * (current_iAppointmentKept.size - previous_iAppointmentKept.size)
    value += 10 * (current_bAppointmentKept.size - previous_bAppointmentKept.size)
    value
  end

  def state(pre, *terms)
    @state[pre].include?(terms)
  end
end