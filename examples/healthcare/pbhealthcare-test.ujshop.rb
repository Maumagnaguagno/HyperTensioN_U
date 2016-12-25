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
satisfied = 'satisfied'

puts 'Test problem 1'
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
    'commitment' => [[c1, c1, bob, alice]],
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
    'patRequestsAssessment' => [],
    'integratedReport' => [],
    'reportNeedsReview' => []
  },
  # Tasks
  [
    ['create', c1, c1, bob, alice, list('nil')],
    ['requestAssessment', alice, bob],
    ['requestImaging', bob, alice, clyde],
    ['requestBiopsy', bob, alice, clyde],
    ['performImaging', clyde, alice, bob],
    ['performBiopsy', clyde, alice, bob],
    ['requestRadiologyReport', bob, clyde, alice],
    ['requestPathologyReport', bob, clyde, doug, alice],

    ['sendRadiologyReport', clyde, bob, alice],
    ['sendPathologyReport', clyde, bob, doug, alice],

    ['sendIntegratedReport', clyde, doug, alice, bob],
    ['generateTreatmentPlan', bob, alice],
    ['reportPatient', alice, doug, evelyn],
    ['addPatientToRegistry', alice, evelyn],
    ['requestPhysicianReportAssessment', alice, bob, simhospital],

    ['testCommitment', c1, c1, list('nil'), satisfied],
  ],
  # Debug
  ARGV.first == '-d',
  # Minimal probability for plans
  ARGV[1] ? ARGV[1].to_f : 0,
  # Maximum plans found
  ARGV[2] ? ARGV[2].to_i : -1
)

puts 'Test problem 2'
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
    'patRequestsAssessment' => [],
    'integratedReport' => [],
    'reportNeedsReview' => []
  },
  # Tasks
  [
    ['create', c1, c1, bob, alice, list('nil')],
    ['requestAssessment', alice, bob],

    ['create', c2, c2, alice, bob, list(clyde)],
    ['create', c3, c3, alice, bob, list(clyde)],

    ['create', c4, c4, clyde, bob, list(doug)],
    ['create', c5, c5, clyde, bob, list(doug)],
    ['create', c6, c6, doug, clyde, list(list(bob, alice))],

    ['create', c7, c7, doug, simhospital, list(list(alice, evelyn))],
    ['create', c8, c8, evelyn, simhospital, list(alice)],

    ['requestImaging', bob, alice, clyde],
    ['requestBiopsy', bob, alice, clyde],
    ['performImaging', clyde, alice, bob],
    ['performBiopsy', clyde, alice, bob],

    ['testCommitment', c2, c2, list(clyde), satisfied],
    ['testCommitment', c3, c3, list(clyde), satisfied],

    ['requestRadiologyReport', bob, clyde, alice],
    ['requestPathologyReport', bob, clyde, doug, alice],

    ['sendRadiologyReport', clyde, bob, alice],
    ['sendPathologyReport', clyde, bob, doug, alice],

    ['testCommitment', c4, c4, list(doug), satisfied],
    ['testCommitment', c5, c5, list(doug), satisfied],
    ['testCommitment', c6, c6, list(list(bob, alice)), satisfied],

    ['sendIntegratedReport', clyde, doug, alice, bob],
    ['generateTreatmentPlan', bob, alice],
    ['reportPatient', alice, doug, evelyn],

    ['testCommitment', c7, c7, list(list(alice, evelyn)), satisfied],

    ['addPatientToRegistry', alice, evelyn],

    ['testCommitment', c8, c8, list(alice), satisfied],

    ['requestPhysicianReportAssessment', alice, bob, simhospital],

    ['testCommitment', c1, c1, list('nil'), satisfied]
  ],
  # Debug
  ARGV.first == '-d',
  # Minimal probability for plans
  ARGV[1] ? ARGV[1].to_f : 0,
  # Maximum plans found
  ARGV[2] ? ARGV[2].to_i : -1
)