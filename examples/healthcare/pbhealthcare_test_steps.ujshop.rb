require_relative 'healthcare'

debug = ARGV.first == 'debug'
max_plans = ARGV[1] ? ARGV[1].to_i : -1
min_prob  = ARGV[2] ? ARGV[2].to_f : 0

# Predicates
PATIENT = 0
PHYSICIAN = 1
RADIOLOGIST = 2
PATHOLOGIST = 3
REGISTRAR = 4
HOSPITAL = 5
PATIENTHASCANCER = 6
COMMITMENT = 7
GOAL = 8
VAR = 9
VARG = 10
DIAGNOSISREQUESTED = 11
IAPPOINTMENTREQUESTED = 12
IAPPOINTMENTKEPT = 13
IMAGINGSCAN = 14
IMAGINGREQUESTED = 15
IMAGINGRESULTSREPORTED = 16
BAPPOINTMENTREQUESTED = 17
BAPPOINTMENTKEPT = 18
BIOPSYREPORT = 19
BIOPSYREQUESTED = 20
RADIOLOGYREQUESTED = 21
TREATMENTPLAN = 22
DIAGNOSISPROVIDED = 23
TISSUEPROVIDED = 24
RADPATHRESULTSREPORTED = 25
PATHRESULTSREPORTED = 26
PATIENTREPORTEDTOREGISTRAR = 27
INREGISTRY = 28
PATHOLOGYREQUESTED = 29
INTEGRATEDREPORT = 30
REPORTNEEDSREVIEW = 31
CANCELLED = 32
RELEASED = 33
EXPIRED = 34
DROPPED = 35
ABORTED = 36
PENDING = 37
ACTIVATEDG = 38
SUSPENDEDG = 39
DONTKNOW = 40

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
  [
    [[alice]], # PATIENT
    [[bob]], # PHYSICIAN
    [[clyde]], # RADIOLOGIST
    [[doug]], # PATHOLOGIST
    [[evelyn]], # REGISTRAR
    [[simhospital]], # HOSPITAL
    [[alice]], # PATIENTHASCANCER
    [ # COMMITMENT
      [C1, C1, bob, alice],
      [C2, C2, alice, bob],
      [C3, C3, alice, bob],
      [C4, C4, clyde, bob],
      [C5, C5, clyde, bob],
      [C6, C6, doug, clyde],
      [C7, C7, evelyn, doug],
    ],
    [ # GOAL
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
    [], # VAR
    [], # VARG
    [], # DIAGNOSISREQUESTED
    [], # IAPPOINTMENTREQUESTED
    [], # IAPPOINTMENTKEPT
    [], # IMAGINGSCAN
    [], # IMAGINGREQUESTED
    [], # IMAGINGRESULTSREPORTED
    [], # BAPPOINTMENTREQUESTED
    [], # BAPPOINTMENTKEPT
    [], # BIOPSYREPORT
    [], # BIOPSYREQUESTED
    [], # RADIOLOGYREQUESTED
    [], # TREATMENTPLAN
    [], # DIAGNOSISPROVIDED
    [], # TISSUEPROVIDED
    [], # RADPATHRESULTSREPORTED
    [], # PATHRESULTSREPORTED
    [], # PATIENTREPORTEDTOREGISTRAR
    [], # INREGISTRY
    [], # PATHOLOGYREQUESTED
    [], # INTEGRATEDREPORT
    [], # REPORTNEEDSREVIEW
    [], # CANCELLED
    [], # RELEASED
    [], # EXPIRED
    [], # DROPPED
    [], # ABORTED
    [], # PENDING
    [], # ACTIVATEDG
    [], # SUSPENDEDG
    [] # DONTKNOW
  ],
  # Tasks
  [
    ['step1', alice],
    ['step2', alice],
    ['step3', alice],
    ['step4', alice],
    ['step5', alice]
  ],
  # Debug
  debug,
  # Maximum plans found
  max_plans,
  # Minimum probability for plans
  min_prob
)

Kernel.abort('Problem failed to generate expected plans') if plans != [
  [0.252, 19,
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
    ['consider', G7, G7, clyde, list(alice)],
    ['activate', G7, G7, clyde, list(alice)],
    ['requestRadiologyReport', bob, clyde, alice],
    ['sendRadiologyReport', clyde, bob, alice],
    ['invisible_testSuccessG', G7, G7, list(alice), satisfied],
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
    ['consider', G13, G13, clyde, list(alice)],
    ['activate', G13, G13, clyde, list(alice)],
    ['performBiopsy_success', clyde, alice, bob],
    ['requestPathologyReport', bob, clyde, doug, alice],
    ['invisible_testSuccessG', G13, G13, list(alice), satisfied],
    ['invisible_testSuccess', C6, C6, list(alice), detached],
    ['consider', G15, G15, doug, list(alice)],
    ['activate', G15, G15, doug, list(alice)],
    ['sendPathologyReport', clyde, bob, doug, alice],
    ['invisible_testSuccessG', G15, G15, list(alice), satisfied],
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
    ['consider', G19, G19, evelyn, list(alice)],
    ['activate', G19, G19, evelyn, list(alice)],
    ['addPatientToRegistry', alice, evelyn],
    ['invisible_testSuccessG', G19, G19, list(alice), satisfied],
    ['invisible_testSuccess', C7, C7, list(alice), satisfied]
  ],
  [0.4 * 0.7 * 0.6, 13,
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
    ['consider', G7, G7, clyde, list(alice)],
    ['activate', G7, G7, clyde, list(alice)],
    ['requestRadiologyReport', bob, clyde, alice],
    ['sendRadiologyReport', clyde, bob, alice],
    ['invisible_testSuccessG', G7, G7, list(alice), satisfied],
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
    ['invisible_testFailure', G11, G11, satisfied],
    ['invisible_testFailure', C3, C3, satisfied],
    ['consider', G12, G12, doug, list(alice)],
    ['activate', G12, G12, doug, list(alice)],
    ['create', C6, C6, doug, clyde, list(alice)],
    ['consider', G13, G13, clyde, list(alice)],
    ['activate', G13, G13, clyde, list(alice)],
    ['performBiopsy_success', clyde, alice, bob],
    ['requestPathologyReport', bob, clyde, doug, alice],
    ['invisible_testSuccessG', G13, G13, list(alice), satisfied],
    ['invisible_testSuccess', C6, C6, list(alice), detached],
    ['consider', G15, G15, doug, list(alice)],
    ['activate', G15, G15, doug, list(alice)],
    ['sendPathologyReport', clyde, bob, doug, alice],
    ['invisible_testSuccessG', G15, G15, list(alice), satisfied],
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
    ['consider', G19, G19, evelyn, list(alice)],
    ['activate', G19, G19, evelyn, list(alice)],
    ['addPatientToRegistry', alice, evelyn],
    ['invisible_testSuccessG', G19, G19, list(alice), satisfied],
    ['invisible_testSuccess', C7, C7, list(alice), satisfied]
  ]
]