# Domain dependent methods

# (:method (hospitalScenario)
#   ((patient ?patient))
#   ((seekHelp ?patient) (processPatient ?patient))
# )

def hospitalScenario_case0
  @state['patient'].each {|terms|
    patient = terms[0]
    yield [
      ['seekHelp', patient],
      ['processPatient', patient]
    ]
  }
end

# (:method (testCommitments)
#   (
#     (commitment C1 ?c1 ?d1 ?a1)
#     (commitment C2 ?c2 ?d2 ?a2)
#     (commitment C3 ?c3 ?d3 ?a3)
#     (commitment C4 ?c4 ?d4 ?a4)
#     (commitment C5 ?c5 ?d5 ?a5)
#     (commitment C6 ?c6 ?d6 ?a6)
#     (commitment C7 ?c7 ?d7 ?a7)
#     (commitment C8 ?c8 ?d8 ?a8)
#   )
#   (
#     (testCommitment C1 ?c1 ?cv1 satisfied)
#     (testCommitment C2 ?c2 ?cv2 satisfied)
#     (testCommitment C3 ?c3 ?cv3 satisfied)
#     (testCommitment C4 ?c4 ?cv4 satisfied)
#     (testCommitment C5 ?c5 ?cv5 satisfied)
#     (testCommitment C6 ?c6 ?cv6 satisfied)
#     (testCommitment C7 ?c7 ?cv7 satisfied)
#     (testCommitment C8 ?c8 ?cv8 satisfied)
#   )
# )

def testCommitments_case0
  c1 = ''
  d1 = ''
  a1 = ''
  c2 = ''
  d2 = ''
  a2 = ''
  c3 = ''
  d3 = ''
  a3 = ''
  c4 = ''
  d4 = ''
  a4 = ''
  c5 = ''
  d5 = ''
  a5 = ''
  c6 = ''
  d6 = ''
  a6 = ''
  c7 = ''
  d7 = ''
  a7 = ''
  c8 = ''
  d8 = ''
  a8 = ''
  generate(
    [
      ['commitment', 'C1', c1, d1, a1],
      ['commitment', 'C2', c2, d2, a2],
      ['commitment', 'C3', c3, d3, a3],
      ['commitment', 'C4', c4, d4, a4],
      ['commitment', 'C5', c5, d5, a5],
      ['commitment', 'C6', c6, d6, a6],
      ['commitment', 'C7', c7, d7, a7],
      ['commitment', 'C8', c8, d8, a8]
    ],
    [], c1, d1, a1, c2, d2, a2, c3, d3, a3, c4, d4, a4, c5, d5, a5, c6, d6, a6, c7, d7, a7, c8, d8, a8
  ) {
    # TODO Variables cv1..cv8 are not bounded
    yield [
      ['testCommitment', 'C1', c1, cv1, 'satisfied'],
      ['testCommitment', 'C2', c2, cv2, 'satisfied'],
      ['testCommitment', 'C3', c3, cv3, 'satisfied'],
      ['testCommitment', 'C4', c4, cv4, 'satisfied'],
      ['testCommitment', 'C5', c5, cv5, 'satisfied'],
      ['testCommitment', 'C6', c6, cv6, 'satisfied'],
      ['testCommitment', 'C7', c7, cv7, 'satisfied'],
      ['testCommitment', 'C8', c8, cv8, 'satisfied'],
    ]
  }
end

# (:method (seekHelp ?patient)
#   ((patient ?patient) (physician ?physician) (radiologist ?radiologist) (commitment C1 ?Ci1 ?physician ?patient))
#   ((!create C1 ?Ci1 ?physician ?patient (nil)) (!requestAssessment ?patient ?physician))
# )

def seekHelp_case0(patient)
  physician = ''
  radiologist = ''
  ci1 = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['commitment', 'C1', ci1, physician, patient]
    ],
    [], physician, radiologist, ci1
  ) {
    # TODO review list containing NIL
    yield [
      ['create', 'C1', ci1, physician, patient, [[]]],
      ['requestAssessment', patient, physician]
    ]
  }
end

# (:method (processPatient ?patient)
#   process-patient-healthy
#   (
#     (patient ?patient) (physician ?physician) (commitment C1 ?Ci ?physician ?patient) (radiologist ?radiologist)
#     ;(conditional C1 ?Ci ?Cv)
#   )
#   ((performImagingTests ?patient) (performPathologyTests ?patient) (deliverDiagnostics ?patient))
# )

def processPatient_process_patient_healthy(patient)
  physician = ''
  radiologist = ''
  ci1 = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['commitment', 'C1', ci1, physician, patient],
      ['radiologist', radiologist]
    ],
    [], physician, radiologist, ci1
  ) {
    # TODO do we need any of the free variables [physician, radiologist, ci1] in this method?
    yield [
      ['performImagingTests', patient],
      ['performPathologyTests', patient],
      ['deliverDiagnostics', patient]
    ]
  }
end

# (:method (performImagingTests ?patient)
#   imaging
#   (
#     (patient ?patient) (physician ?physician) (commitment C1 ?Ci ?physician ?patient)
#     (radiologist ?radiologist)
#     (pathologist ?pathologist)
#     ;(conditional C1 ?Ci ?Cv)
#     (commitment C2 ?Ci2 ?patient ?physician)
#     (commitment C5 ?Ci5 ?radiologist ?physician)
#   )
#   (
#     (!create C2 ?Ci2 ?patient ?physician (?radiologist))
#     (!create C5 ?Ci5 ?radiologist ?physician (?pathologist))
#     (!requestImaging ?physician ?patient ?radiologist)
#     (attendTest ?patient)
#   )
# )

def performImagingTests_imaging(patient)
  physician = ''
  ci = ''
  radiologist = ''
  pathologist = ''
  ci2 = ''
  ci5 = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['commitment', 'C1', ci, physician, patient],
      ['radiologist', radiologist],
      ['pathologist', pathologist],
      ['commitment', 'C2', ci2, patient, physician],
      ['commitment', 'C5', ci5, radiologist, physician]
    ],
    [], physician, ci, radiologist, pathologist, ci2, ci5
  ) {
    # TODO review lists in the subtasks
    yield [
      ['create', 'C2', ci2, patient, physician, [radiologist]],
      ['create', 'C5', ci5, radiologist, physician, [pathologist]],
      ['requestImaging', physician, patient, radiologist],
      ['attendTest', patient]
    ]
  }
end

# (:method (performPathologyTests ?patient)
#   biopsy-unnecessary
#   ((patient ?patient) (physician ?physician) (commitment C1 ?Ci ?physician ?patient) (radiologist ?radiologist))
#   ()
# )

def performPathologyTests_biopsy_unnecessary(patient)
  # TODO review radiologist variable in the preconditions
  physician = ''
  ci = ''
  radiologist = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['commitment', 'C1', ci, physician, patient],
      ['radiologist', radiologist]
    ],
    [], physician, ci, radiologist
  ) {
    yield []
  }
end

# (:method (performPathologyTests ?patient)
#   imaging-plus-biopsy
#   (
#     (patient ?patient) (physician ?physician)
#     (radiologist ?radiologist)
#     (pathologist ?pathologist)
#     ;(conditional C1 ?Ci ?Cv)
#     (commitment C3 ?Ci3 ?patient ?physician)
#     (commitment C4 ?Ci4 ?radiologist ?physician)
#   )
#   (
#     (!create C3 ?Ci3 ?patient ?physician (?radiologist))
#     (!create C4 ?Ci4 ?radiologist ?physician (?pathologist))
#     (!requestBiopsy ?physician ?patient ?radiologist)
#     (attendTest ?patient)
#   )
# )

def performPathologyTests_imaging_plus_biopsy(patient)
  physician = ''
  radiologist = ''
  pathologist = ''
  ci = ''
  cv = ''
  ci3 = ''
  ci4 = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['pathologist', pathologist],
      ['commitment', 'C3', ci3, patient, physician],
      ['commitment', 'C4', ci4, radiologist, physician]
    ],
    [], physician, radiologist, pathologist, ci, cv, ci3, ci4
  ) {
    # TODO review lists in the subtasks
    yield [
      ['create', 'C3', ci3, patient, physician, [radiologist]],
      ['create', 'C4', ci4, radiologist, physician, [pathologist]],
      ['requestBiopsy', physician, patient, radiologist],
      ['attendTest', patient]
    ]
  }
end

# (:method (attendTest ?patient)
#   attend-imaging
#   ((patient ?patient) (physician ?physician) (radiologist ?radiologist) (iAppointmentRequested ?patient ?radiologist) (not (iAppointmentKept ?patient ?radiologist)))
#   ((!performImaging ?radiologist ?patient ?physician))
#   attend-biopsy
#   ((patient ?patient) (physician ?physician) (radiologist ?radiologist) (bAppointmentRequested ?patient ?radiologist) (not (bAppointmentKept ?patient ?radiologist)))
#   ((!performBiopsy ?radiologist ?patient ?physician))
# )

def attendTest_attend_imaging(patient)
  physician = ''
  radiologist = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['iAppointmentRequested', patient, radiologist]
    ],
    [
      ['iAppointmentKept', patient, radiologist]
    ], physician, radiologist
  ) {
    yield [['performImaging', radiologist, patient, physician]]
  }
end

def attendTest_attend_biopsy(patient)
  physician = ''
  radiologist = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['bAppointmentRequested', patient, radiologist]
    ],
    [
      ['bAppointmentKept', patient, radiologist]
    ], physician, radiologist
  ) {
    yield [['performBiopsy', radiologist, patient, physician]]
  }
end

# (:method (attendTest ?patient)
#   no-show-imaging
#   ((patient ?patient) (physician ?physician) (radiologist ?radiologist) (iAppointmentRequested ?patient ?radiologist) (not (iAppointmentKept ?patient ?radiologist)))
#   () ; No show
#   no-show-biopsy
#   ((patient ?patient) (physician ?physician) (radiologist ?radiologist) (bAppointmentRequested ?patient ?radiologist) (not (bAppointmentKept ?patient ?radiologist)))
#   ()
# )

def attendTest_no_show_imaging(patient)
  physician = ''
  radiologist = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['iAppointmentRequested', patient, radiologist]
    ],
    [
      ['bAppointmentKept', patient, radiologist]
    ], physician, radiologist
  ) {
    yield []
  }
end

def attendTest_no_show_biopsy(patient)
  physician = ''
  radiologist = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['bAppointmentRequested', patient, radiologist]
    ],
    [
      ['bAppointmentKept', patient, radiologist]
    ], physician, radiologist
  ) {
    yield []
  }
end

# (:method (deliverDiagnostics ?patient)
#   only-imaging
#   ((patient ?patient) (physician ?physician) (radiologist ?radiologist) (iAppointmentKept ?patient ?radiologist) (not (biopsyRequested ?physician ?patient)))
#   (
#     (!requestRadiologyReport ?physician ?radiologist ?patient)
#     (!sendRadiologyReport ?radiologist ?physician ?patient)
#     (!generateTreatmentPlan ?physician ?patient)
#   )
#   imaging-biopsy-integrated
#   ((patient ?patient) (physician ?physician) (radiologist ?radiologist) (pathologist ?pathologist) (iAppointmentKept ?patient ?radiologist) (bAppointmentKept ?patient ?radiologist))
#   (
#     (!requestRadiologyReport ?physician ?radiologist ?patient)
#     (!requestPathologyReport ?physician ?radiologist ?patient)
#     (!sendRadiologyReport ?radiologist ?physician ?patient)
#     (!sendPathologyReport ?radiologist ?physician ?patient)
#     (!sendIntegratedReport ?radiologist ?pathologist ?patient ?physician)
#     (!generateTreatmentPlan ?physician ?patient)
#   )
# )

def deliverDiagnostics_only_imaging(patient)
  physician = ''
  radiologist = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['iAppointmentKept', patient, radiologist]
    ],
    [
      ['biopsyRequested', physician, patient]
    ], physician, radiologist
  ) {
    yield [
      ['requestRadiologyReport', physician, radiologist, patient],
      ['sendRadiologyReport', radiologist, physician, patient],
      ['generateTreatmentPlan', physician, patient]
    ]
  }
end

def deliverDiagnostics_imaging_biopsy_integrated(patient)
  physician = ''
  radiologist = ''
  pathologist = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['pathologist', pathologist],
      ['iAppointmentKept', patient, radiologist],
      ['bAppointmentKept', patient, radiologist]
    ],
    [], physician, radiologist, pathologist
  ) {
    yield [
      ['requestRadiologyReport', physician, radiologist, patient],
      ['requestPathologyReport', physician, radiologist, patient],
      ['sendRadiologyReport', radiologist, physician, patient],
      ['sendPathologyReport', radiologist, physician, patient],
      ['sendIntegratedReport', radiologist, pathologist, patient, physician],
      ['generateTreatmentPlan', physician, patient]
    ]
  }
end