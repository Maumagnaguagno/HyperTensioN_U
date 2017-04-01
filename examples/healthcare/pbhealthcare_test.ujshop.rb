require_relative 'healthcare'

debug = ARGV.first == '-d'
max_plans = ARGV[1] ? ARGV[1].to_i : -1
min_prob  = ARGV[2] ? ARGV[2].to_f : 0

# Objects
alice = 'alice'
bob = 'bob'
clyde = 'clyde'
doug = 'doug'
evelyn = 'evelyn'
simhospital = 'simhospital'
satisfied = 'satisfied'
detached = 'detached'

plans = Healthcare.problem(
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
      [C1, C1, bob, alice],
      [C2, C2, alice, bob],
      [C3, C3, alice, bob],
      [C4, C4, clyde, bob],
      [C5, C5, clyde, bob],
      [C6, C6, doug, clyde],
      [C7, C7, evelyn, doug],
    ],
    'goal' => [
      [G1,  G1, bob],
      [G2,  G2, alice],
      [G3,  G3, clyde],
      [G4,  G4, bob],
      [G6,  G6, alice],
      [G7,  G7, clyde],
      [G8,  G8, clyde],
      [G9,  G9, bob],
      [G11, G11, alice],
      [G12, G12, doug],
      [G13, G13, clyde],
      [G15, G15, doug],
      [G16, G16, clyde],
      [G17, G17, evelyn],
      [G18, G18, doug],
      [G19, G19, evelyn],
    ],
    'var' => [],
    'varG' => [],
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
    'pathologyRequested' => [],
    'integratedReport' => [],
    'reportNeedsReview' => [],
    'cancelled' => [],
    'released' => [],
    'expired' => [],
    'dropped' => [],
    'aborted' => [],
    'pending' => [],
    'activatedG' => [],
    'suspendedG' => [],
    'dontknow' => []
  },
  # Tasks
  [
    # Physician considers and activates G1
    ['consider', G1, G1, bob, list(alice)],
    ['activate', G1, G1, bob, list(alice)],

    # Physician employs ENTICE rule to create C1
    ['entice', G1, G1, list(alice), C1, C1, list(alice), bob, alice],

    # Patient employs DETACH for C1 which results in considering and activating of G2
    ['detach', G2, G2, list(alice), C1, C1, list(alice), bob, alice],

    # TODO: DETACH should also create C2 and C3. Since it does not, creating
    # C2 and C3 explicitly
    ['create', C2, C2, alice, bob, list(clyde)],
    ['create', C3, C3, alice, bob, list(clyde)],

    # Patient brings about requestAssessment
    ['requestAssessment', alice, bob],

    # The above should satisfy G1 and G2 and detach C1
    ['testGoal', G1, G1, list(alice), satisfied],
    ['testGoal', G2, G2, list(alice), satisfied],
    ['testCommitment', C1, C1, list(alice), detached],

    #;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    # Radiologist considers and activates G3
    ['consider', G3, G3, clyde, list(alice)],
    ['activate', G3, G3, clyde, list(alice)],

    # Radiologist employs ENTICE for G3 to create C4
    ['entice', G3, G3, list(alice), C4, C4, list(alice), clyde, bob],

    # Physician employs DETACH for C4 to create G4
    ['detach', G4, G4, list(alice), C4, C4, list(alice), clyde, bob],

    # Physician brings about imagingRequested and iAppointmentRequested
    ['requestImaging', bob, alice, clyde],

    # The above should satisfy G4 and detach C2
    ['testGoal', G4, G4, list(alice), satisfied],
    ['testCommitment', C2, C2, list(clyde), detached],

    # Patient employs DELIVER for C2 to consider and activate goal G6
    ['deliver', G6, G6, list(alice), C2, C2, list(clyde), alice, bob],

    # Patient brings about iAppointmentKept
    ['attendTest', alice],
    ['testCommitment', C4, C4, list(alice), detached], # TODO This won't detach C4 because it also requires the imaging appotintment to have been kept (this only happens attendTest below)

    # The above should satisfy G6 and C2
    ['testGoal', G6, G6, list(alice), satisfied],
    ['testCommitment', C2, C2, list(clyde), satisfied],

    # Radiologist employs DELIVER for C4 to consider and activate goal G7
    ['deliver', G7, G7, list(clyde), C4, C4, list(alice), clyde, bob],

    # Physician requests radiology report
    ['requestRadiologyReport', bob, clyde, alice],
    # Radiologist brings about imagingResultsReported
    ['sendRadiologyReport', clyde, bob, alice],

    # The above should satisfy G7 and C4
    ['testGoal', G7, G7, list(clyde), satisfied],
    ['testCommitment', C4, C4, list(alice), satisfied],

    #;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    # Radiologist considers and activates goal G8
    ['consider', G8, G8, clyde, list(alice)],
    ['activate', G8, G8, clyde, list(alice)],

    # Radiologist employs ENTICE for G8 to create commitment C5
    ['entice', G8, G8, list(alice), C5, C5, list(alice), clyde, bob],

    # Physician employs DETACH for C5 to consider and activate goal G9
    ['detach', G9, G9, list(alice), C5, C5, list(alice), clyde, bob],

    # Physician brings about biopsyRequested and bAppointmentRequested.
    ['requestBiopsy', bob, alice, clyde],

    # The above should satisfy G9 and detach C3
    ['testGoal', G9, G9, list(alice), satisfied],
    ['testCommitment', C3, C3, list(clyde), detached],

    # Patient employs DELIVER for C3 to consider and activate goal G11
    ['deliver', G11, G11, list(alice), C3, C3, list(clyde), alice, bob],

    # Patient brings about bAppointmentKept
    ['performBiopsy', clyde, alice, bob],

    # The above should detach C4
    ['testCommitment', C5, C5, list(alice), detached],

    # The above should satisfy G11 and C3
    ['testGoal', G11, G11, list(alice), satisfied],
    ['testCommitment', C3, C3, list(clyde), satisfied],

    #;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    # Pathologist considers and activates goal G12
    ['consider', G12, G12, doug, list(alice)],
    ['activate', G12, G12, doug, list(alice)],

    # Pathologist employs ENTICE for G12 to create commitment C6
    ['entice', G12, G12, list(alice), C6, C6, list(alice), doug, clyde],

    # Radiologist employs DETACH for C6 to consider and activate goal G13
    ['detach', G13, G13, list(clyde), C6, C6, list(alice), doug, clyde],

    # Radiologist brings about pathologyRequested and tissueProvided
    ['performBiopsy', clyde, alice, bob],
    ['requestPathologyReport', bob, clyde, doug, alice],

    # The above should satisfy G13 and detach C6
    ['testGoal', G13, G13, list(clyde), satisfied],
    ['testCommitment', C6, C6, list(alice), detached],

    # Pathologist employs DELIVER for C6 to consider and activate goal G15
    ['deliver', G15, G15, list(doug), C6, C6, list(alice), doug, clyde],

    # Pathologist brings about pathResultsReported
    ['sendPathologyReport', clyde, bob, doug, alice],

    # The above should satisfy G15 and C6
    ['testGoal', G15, G15, list(doug), satisfied],
    ['testCommitment', C6, C6, list(alice), satisfied],

    # Radiologist employs DELIVER for C5 to consider and activate goal G16
    ['deliver', G16, G16, list(alice), C5, C5, list(alice), clyde, bob],

    # Radiologist brings about radPathResultsReported
    ['sendRadiologyReport', clyde, bob, alice],
    ['sendIntegratedReport', clyde, doug, alice, bob],

    # The above should satisfies G16 and C5
    ['testGoal', G16, G16, list(alice), satisfied],
    ['testCommitment', C5, C5, list(alice), satisfied],

    #;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    # Registrar considers and activates goal
    ['consider', G17, G17, evelyn, list(alice)],
    ['activate', G17, G17, evelyn, list(alice)],

    # Registrar employs ENTICE for G17 to create commitment C7
    ['entice', G17, G17, list(alice), C7, C7, list(alice), evelyn, doug],

    # Pathologist employs DETACH rule if patient has cancer to consider and activate goal G18
    ['detach', G18, G18, list(doug), C7, C7, list(alice), evelyn, doug],

    # Pathologist reports patient to registrar
    ['reportPatient', alice, doug, evelyn],

    # The above should satisfies G16 and C5
    ['testGoal', G17, G17, list(alice), satisfied],
    ['testCommitment', C7, C7, list(alice), detached],

    # Registrar employs DELIVER rule for C7 to consider and activate goal G19
    ['deliver', G19, G19, list(evelyn), C7, C7, list(alice), evelyn, doug],

    # Registrar brings about addPatientToRegistry. This:
    ['addPatientToRegistry', alice, evelyn],

    # The above should satisfy G19 and C7
    ['testGoal', G19, G19, list(evelyn), satisfied],
    ['testCommitment', C7, C7, list(alice), satisfied]
  ],
  # Debug
  debug,
  # Maximum plans found
  max_plans,
  # Minimum probability for plans
  min_prob
)

Kernel.abort('Problem failed to generate expected plans') if plans != [
  [0.252, 0,
    ['consider', G1, G1, bob, list(alice)],
    ['activate', G1, G1, bob, list(alice)],
    ['create', C1, C1, bob, alice, list(alice)],
    ['consider', G2, G2, alice, list(alice)],
    ['activate', G2, G2, alice, list(alice)],
    ['create', C2, C2, alice, bob, list(clyde)],
    ['create', C3, C3, alice, bob, list(clyde)],
    ['requestAssessment', alice, bob],
    ['invisible_testSuccessG', G1, G1, list(alice), satisfied],
    ['invisible_testSuccessG', G2, G2, list(alice), satisfied],
    ['invisible_testSuccess', C1, C1, list(alice), detached],
    ['consider', G3, G3, clyde, list(alice)],
    ['activate', G3, G3, clyde, list(alice)],
    ['create', C4, C4, clyde, bob, list(alice)],
    ['consider', G4, G4, bob, list(alice)],
    ['activate', G4, G4, bob, list(alice)],
    ['requestImaging', bob, alice, clyde],
    ['invisible_testSuccessG', G4, G4, list(alice), satisfied],
    ['invisible_testSuccess', C2, C2, list(clyde), detached],
    ['consider', G6, G6, alice, list(alice)],
    ['activate', G6, G6, alice, list(alice)],
    ['performImaging_success', clyde, alice, bob],
    ['invisible_testSuccess', C4, C4, list(alice), detached],
    ['invisible_testSuccessG', G6, G6, list(alice), satisfied],
    ['invisible_testSuccess', C2, C2, list(clyde), satisfied],
    ['consider', G7, G7, clyde, list(clyde)],
    ['activate', G7, G7, clyde, list(clyde)],
    ['requestRadiologyReport', bob, clyde, alice],
    ['sendRadiologyReport', clyde, bob, alice],
    ['invisible_testSuccessG', G7, G7, list(clyde), satisfied],
    ['invisible_testSuccess', C4, C4, list(alice), satisfied],
    ['consider', G8, G8, clyde, list(alice)],
    ['activate', G8, G8, clyde, list(alice)],
    ['create', C5, C5, clyde, bob, list(alice)],
    ['consider', G9, G9, bob, list(alice)],
    ['activate', G9, G9, bob, list(alice)],
    ['requestBiopsy', bob, alice, clyde],
    ['invisible_testSuccessG', G9, G9, list(alice), satisfied],
    ['invisible_testSuccess', C3, C3, list(clyde), detached],
    ['consider', G11, G11, alice, list(alice)],
    ['activate', G11, G11, alice, list(alice)],
    ['performBiopsy_success', clyde, alice, bob],
    ['invisible_testSuccess', C5, C5, list(alice), detached],
    ['invisible_testSuccessG', G11, G11, list(alice), satisfied],
    ['invisible_testSuccess', C3, C3, list(clyde), satisfied],
    ['consider', G12, G12, doug, list(alice)],
    ['activate', G12, G12, doug, list(alice)],
    ['create', C6, C6, doug, clyde, list(alice)],
    ['consider', G13, G13, clyde, list(clyde)],
    ['activate', G13, G13, clyde, list(clyde)],
    ['performBiopsy_success', clyde, alice, bob],
    ['requestPathologyReport', bob, clyde, doug, alice],
    ['invisible_testSuccessG', G13, G13, list(clyde), satisfied],
    ['invisible_testSuccess', C6, C6, list(alice), detached],
    ['consider', G15, G15, doug, list(doug)],
    ['activate', G15, G15, doug, list(doug)],
    ['sendPathologyReport', clyde, bob, doug, alice],
    ['invisible_testSuccessG', G15, G15, list(doug), satisfied],
    ['invisible_testSuccess', C6, C6, list(alice), satisfied],
    ['consider', G16, G16, clyde, list(alice)],
    ['activate', G16, G16, clyde, list(alice)],
    ['sendRadiologyReport', clyde, bob, alice],
    ['sendIntegratedReport', clyde, doug, alice, bob],
    ['invisible_testSuccessG', G16, G16, list(alice), satisfied],
    ['invisible_testSuccess', C5, C5, list(alice), satisfied],
    ['consider', G17, G17, evelyn, list(alice)],
    ['activate', G17, G17, evelyn, list(alice)],
    ['create', C7, C7, evelyn, doug, list(alice)],
    ['consider', G18, G18, doug, list(doug)],
    ['activate', G18, G18, doug, list(doug)],
    ['reportPatient', alice, doug, evelyn],
    ['invisible_testSuccessG', G17, G17, list(alice), satisfied],
    ['invisible_testSuccess', C7, C7, list(alice), detached],
    ['consider', G19, G19, evelyn, list(evelyn)],
    ['activate', G19, G19, evelyn, list(evelyn)],
    ['addPatientToRegistry', alice, evelyn],
    ['invisible_testSuccessG', G19, G19, list(evelyn), satisfied],
    ['invisible_testSuccess', C7, C7, list(alice), satisfied]
  ],
  [0.4 * 0.7 * 0.6, 0,
    ['consider', G1, G1, bob, list(alice)],
    ['activate', G1, G1, bob, list(alice)],
    ['create', C1, C1, bob, alice, list(alice)],
    ['consider', G2, G2, alice, list(alice)],
    ['activate', G2, G2, alice, list(alice)],
    ['create', C2, C2, alice, bob, list(clyde)],
    ['create', C3, C3, alice, bob, list(clyde)],
    ['requestAssessment', alice, bob],
    ['invisible_testSuccessG', G1, G1, list(alice), satisfied],
    ['invisible_testSuccessG', G2, G2, list(alice), satisfied],
    ['invisible_testSuccess', C1, C1, list(alice), detached],
    ['consider', G3, G3, clyde, list(alice)],
    ['activate', G3, G3, clyde, list(alice)],
    ['create', C4, C4, clyde, bob, list(alice)],
    ['consider', G4, G4, bob, list(alice)],
    ['activate', G4, G4, bob, list(alice)],
    ['requestImaging', bob, alice, clyde],
    ['invisible_testSuccessG', G4, G4, list(alice), satisfied],
    ['invisible_testSuccess', C2, C2, list(clyde), detached],
    ['consider', G6, G6, alice, list(alice)],
    ['activate', G6, G6, alice, list(alice)],
    ['performImaging_success', clyde, alice, bob],
    ['invisible_testSuccess', C4, C4, list(alice), detached],
    ['invisible_testSuccessG', G6, G6, list(alice), satisfied],
    ['invisible_testSuccess', C2, C2, list(clyde), satisfied],
    ['consider', G7, G7, clyde, list(clyde)],
    ['activate', G7, G7, clyde, list(clyde)],
    ['requestRadiologyReport', bob, clyde, alice],
    ['sendRadiologyReport', clyde, bob, alice],
    ['invisible_testSuccessG', G7, G7, list(clyde), satisfied],
    ['invisible_testSuccess', C4, C4, list(alice), satisfied],
    ['consider', G8, G8, clyde, list(alice)],
    ['activate', G8, G8, clyde, list(alice)],
    ['create', C5, C5, clyde, bob, list(alice)],
    ['consider', G9, G9, bob, list(alice)],
    ['activate', G9, G9, bob, list(alice)],
    ['requestBiopsy', bob, alice, clyde],
    ['invisible_testSuccessG', G9, G9, list(alice), satisfied],
    ['invisible_testSuccess', C3, C3, list(clyde), detached],
    ['consider', G11, G11, alice, list(alice)],
    ['activate', G11, G11, alice, list(alice)],
    ['performBiopsy_failure', clyde, alice, bob],
    ['invisible_testFailure', G11, satisfied],
    ['invisible_testFailure', C3, satisfied],
    ['consider', G12, G12, doug, list(alice)],
    ['activate', G12, G12, doug, list(alice)],
    ['create', C6, C6, doug, clyde, list(alice)],
    ['consider', G13, G13, clyde, list(clyde)],
    ['activate', G13, G13, clyde, list(clyde)],
    ['performBiopsy_success', clyde, alice, bob],
    ['requestPathologyReport', bob, clyde, doug, alice],
    ['invisible_testSuccessG', G13, G13, list(clyde), satisfied],
    ['invisible_testSuccess', C6, C6, list(alice), detached],
    ['consider', G15, G15, doug, list(doug)],
    ['activate', G15, G15, doug, list(doug)],
    ['sendPathologyReport', clyde, bob, doug, alice],
    ['invisible_testSuccessG', G15, G15, list(doug), satisfied],
    ['invisible_testSuccess', C6, C6, list(alice), satisfied],
    ['consider', G16, G16, clyde, list(alice)],
    ['activate', G16, G16, clyde, list(alice)],
    ['sendRadiologyReport', clyde, bob, alice],
    ['sendIntegratedReport', clyde, doug, alice, bob],
    ['invisible_testSuccessG', G16, G16, list(alice), satisfied],
    ['invisible_testSuccess', C5, C5, list(alice), satisfied],
    ['consider', G17, G17, evelyn, list(alice)],
    ['activate', G17, G17, evelyn, list(alice)],
    ['create', C7, C7, evelyn, doug, list(alice)],
    ['consider', G18, G18, doug, list(doug)],
    ['activate', G18, G18, doug, list(doug)],
    ['reportPatient', alice, doug, evelyn],
    ['invisible_testSuccessG', G17, G17, list(alice), satisfied],
    ['invisible_testSuccess', C7, C7, list(alice), detached],
    ['consider', G19, G19, evelyn, list(evelyn)],
    ['activate', G19, G19, evelyn, list(evelyn)],
    ['addPatientToRegistry', alice, evelyn],
    ['invisible_testSuccessG', G19, G19, list(evelyn), satisfied],
    ['invisible_testSuccess', C7, C7, list(alice), satisfied]
  ]
]