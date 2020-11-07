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

plan = Healthcare.problem(
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
      [C7, C7, doug, simhospital],
      [C8, C8, evelyn, simhospital]
    ],
    [], # GOAL
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
    ['hospitalScenario'],
    ['testCommitments']
  ],
  # Debug
  debug,
  # Maximum plans found
  max_plans,
  # Minimum probability for plans
  min_prob
)

Kernel.abort('Problem failed to generate expected plan') if plan != [
  [0.7, 7,
    ['create', C1, C1, bob, alice, list(alice)],
    ['requestAssessment', alice, bob],
    ['create', C2, C2, alice, bob, list(clyde)],
    ['create', C5, C5, clyde, bob, list(doug)],
    ['requestImaging', bob, alice, clyde],
    ['performImaging_success', clyde, alice, bob],
    ['requestRadiologyReport', bob, clyde, alice],
    ['sendRadiologyReport', clyde, bob, alice],
    ['generateTreatmentPlan', bob, alice],
    ['invisible_testSuccess', C1, C1, list(alice), satisfied],
    ['invisible_testSuccess', C2, C2, list(clyde), satisfied],
    ['invisible_testFailure', C3, C3, satisfied],
    ['invisible_testFailure', C4, C4, satisfied],
    ['invisible_testFailure', C5, C5, satisfied],
    ['invisible_testFailure', C6, C6, satisfied],
    ['invisible_testFailure', C7, C7, satisfied],
    ['invisible_testFailure', C8, C8, satisfied]
  ]
]