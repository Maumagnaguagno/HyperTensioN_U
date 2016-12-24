require_relative 'healthcare'

# Objects
alice = 'alice'
bob = 'bob'
clyde = 'clyde'
doug = 'doug'
evelyn = 'evelyn'
simhospital = 'simhospital'
c1 = 'C1'
c2 = 'C2'
c3 = 'C3'
c4 = 'C4'
c5 = 'C5'
c6 = 'C6'
c7 = 'C7'
c8 = 'C8'

Healthcare.problem(
  # Start
  {
    'patient' => [[alice]],
    'physician' => [[bob]],
    'radiologist' => [[clyde]],
    'pathologist' => [[doug]],
    'registrar' => [[evelyn]],
    'hospital' => [[simhospital]],
    'patientHasCancer' => [[alice]],
    'commitment' => [
      [c1, c1, bob, alice],
      [c2, c2, alice, bob],
      [c3, c3, alice, bob],
      [c4, c4, clyde, bob],
      [c5, c5, clyde, bob],
      [c6, c6, doug, clyde],
      [c7, c7, doug, simhospital],
      [c8, c8, evelyn, simhospital]
    ],
    'var' => [],
    'diagnosisRequested' => [],
    'iAppointmentRequested' => [],
    'iAppointmentKept' => [],
    'imagingScan' => [],
    'imagingRequested' => [],
    'imagingResultsReported' => [],
    'bAppointmentRequested' => [],
    'bAppointmentKept' => [],
    'biopsyReport' => [],
    'biopsyRequested' => [],
    'radiologyRequested' => [],
    'treatmentPlan' => [],
    'diagnosisProvided' => [],
    'tissueProvided' => [],
    'radPathResultsReported' => [],
    'pathResultsReported' => [],
    'patientReportedToRegistrar' => [],
    'inRegistry' => [],
    'TBAgreesPath' => [],
    'TBDisagreesPath' => [],
    'TBAgreesRad' => [],
    'TBDisagreesRad' => [],
    'TBAgreesPCP' => [],
    'TBDisagreesPCP' => [],
    'pathologyRequested' => [],
    'escalate' => [],
    'radRequestsAssessment' => [],
    'phyRequestsAssessment' => [],
    'patRequestsAssessment' => []
  },
  # Tasks
  [
    ['hospitalScenario'],
    ['testCommitments']
  ],
  # Debug
  ARGV.first == '-d',
  # Minimal probability for plans
  ARGV[1] ? ARGV[1].to_f : 0,
  # Maximum plans found
  ARGV[2] ? ARGV[2].to_i : -1
)